"""
BlockScore Backend - Production-Ready Flask Application
Financial Industry Standards Implementation
"""

import logging
import traceback
from datetime import datetime, timezone

import redis

# Import configuration and models
from config import get_config
from flask import Flask, g, jsonify, request
from flask_bcrypt import Bcrypt
from flask_cors import CORS
from flask_jwt_extended import (
    JWTManager,
    create_access_token,
    create_refresh_token,
    get_jwt,
    get_jwt_identity,
    jwt_required,
)
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address
from models import db, ma
from models.audit import AuditEventType, AuditSeverity
from models.credit import CreditHistory, CreditScore
from models.loan import LoanApplication, LoanApplicationSchema
from models.user import User, UserLoginSchema, UserRegistrationSchema
from services.audit_service import AuditService

# Import services
from services.auth_service import AuthService
from services.blockchain_service import BlockchainService
from services.compliance_service import ComplianceService
from services.credit_service import CreditScoringService


def create_app(config_name="default"):
    """Application factory pattern"""
    app = Flask(__name__)

    # Load configuration
    config_class = get_config()
    app.config.from_object(config_class)

    # Initialize extensions
    db.init_app(app)
    ma.init_app(app)

    # Initialize CORS
    CORS(app, origins="*", methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"])

    # Initialize JWT
    jwt = JWTManager(app)

    # Initialize Bcrypt
    bcrypt = Bcrypt(app)

    # Initialize Redis for rate limiting and caching
    try:
        redis_client = redis.from_url(app.config["REDIS_URL"])
        redis_client.ping()
    except Exception as e:
        print(f"Redis connection failed: {e}")
        redis_client = None

    # Initialize rate limiter
    limiter = Limiter(
        app,
        key_func=get_remote_address,
        storage_uri=app.config["RATELIMIT_STORAGE_URL"] if redis_client else None,
        default_limits=[app.config["RATELIMIT_DEFAULT"]],
    )

    # Initialize services
    auth_service = AuthService(db, bcrypt, redis_client)
    credit_service = CreditScoringService(db)
    blockchain_service = BlockchainService(app.config)
    audit_service = AuditService(db)
    ComplianceService(db)

    # JWT token blacklist
    blacklisted_tokens = set()

    @jwt.token_in_blocklist_loader
    def check_if_token_revoked(jwt_header, jwt_payload):
        return jwt_payload["jti"] in blacklisted_tokens

    # Request logging middleware
    @app.before_request
    def before_request():
        g.start_time = datetime.now(timezone.utc)
        g.request_id = str(uuid.uuid4())[:8]

        # Log request
        app.logger.info(
            f"[{g.request_id}] {request.method} {request.url} - IP: {request.remote_addr}"
        )

    @app.after_request
    def after_request(response):
        # Calculate response time
        if hasattr(g, "start_time"):
            response_time = (
                datetime.now(timezone.utc) - g.start_time
            ).total_seconds() * 1000

            # Log response
            app.logger.info(
                f"[{g.request_id}] Response: {response.status_code} - Time: {response_time:.2f}ms"
            )

            # Create audit log for API requests
            try:
                audit_service.log_api_request(
                    request_method=request.method,
                    request_url=request.url,
                    response_status=response.status_code,
                    response_time_ms=int(response_time),
                    ip_address=request.remote_addr,
                    user_agent=request.headers.get("User-Agent"),
                    user_id=(
                        get_jwt_identity()
                        if hasattr(request, "headers")
                        and "Authorization" in request.headers
                        else None
                    ),
                )
            except Exception as e:
                app.logger.error(f"Failed to create audit log: {e}")

        return response

    # Error handlers
    @app.errorhandler(400)
    def bad_request(error):
        return (
            jsonify(
                {
                    "success": False,
                    "error": "Bad Request",
                    "message": "The request could not be understood by the server due to malformed syntax.",
                    "request_id": getattr(g, "request_id", None),
                }
            ),
            400,
        )

    @app.errorhandler(401)
    def unauthorized(error):
        return (
            jsonify(
                {
                    "success": False,
                    "error": "Unauthorized",
                    "message": "Authentication is required to access this resource.",
                    "request_id": getattr(g, "request_id", None),
                }
            ),
            401,
        )

    @app.errorhandler(403)
    def forbidden(error):
        return (
            jsonify(
                {
                    "success": False,
                    "error": "Forbidden",
                    "message": "You do not have permission to access this resource.",
                    "request_id": getattr(g, "request_id", None),
                }
            ),
            403,
        )

    @app.errorhandler(404)
    def not_found(error):
        return (
            jsonify(
                {
                    "success": False,
                    "error": "Not Found",
                    "message": "The requested resource could not be found.",
                    "request_id": getattr(g, "request_id", None),
                }
            ),
            404,
        )

    @app.errorhandler(429)
    def rate_limit_exceeded(error):
        return (
            jsonify(
                {
                    "success": False,
                    "error": "Rate Limit Exceeded",
                    "message": "Too many requests. Please try again later.",
                    "request_id": getattr(g, "request_id", None),
                }
            ),
            429,
        )

    @app.errorhandler(500)
    def internal_error(error):
        app.logger.error(f"Internal server error: {error}")
        app.logger.error(traceback.format_exc())
        return (
            jsonify(
                {
                    "success": False,
                    "error": "Internal Server Error",
                    "message": "An unexpected error occurred. Please try again later.",
                    "request_id": getattr(g, "request_id", None),
                }
            ),
            500,
        )

    # Health check endpoint
    @app.route("/api/health", methods=["GET"])
    def health_check():
        """Comprehensive health check endpoint"""
        try:
            # Check database connection
            db.session.execute("SELECT 1")
            db_status = True
        except Exception as e:
            db_status = False
            app.logger.error(f"Database health check failed: {e}")

        # Check Redis connection
        redis_status = False
        if redis_client:
            try:
                redis_client.ping()
                redis_status = True
            except Exception as e:
                app.logger.error(f"Redis health check failed: {e}")

        # Check blockchain connection
        blockchain_status = blockchain_service.is_connected()

        # Overall health status
        is_healthy = db_status and (redis_status or not redis_client)

        return jsonify(
            {
                "success": True,
                "status": "healthy" if is_healthy else "unhealthy",
                "timestamp": datetime.now(timezone.utc).isoformat(),
                "version": "1.0.0",
                "services": {
                    "database": "up" if db_status else "down",
                    "redis": (
                        "up"
                        if redis_status
                        else "down" if redis_client else "not_configured"
                    ),
                    "blockchain": "up" if blockchain_status else "down",
                    "ai_model": "up" if credit_service.is_model_loaded() else "down",
                },
                "request_id": getattr(g, "request_id", None),
            }
        ), (200 if is_healthy else 503)

    # Authentication endpoints
    @app.route("/api/auth/register", methods=["POST"])
    @limiter.limit("5 per minute")
    def register():
        """User registration endpoint"""
        try:
            # Validate request data
            schema = UserRegistrationSchema()
            data = schema.load(request.json)

            # Check if user already exists
            existing_user = User.query.filter_by(email=data["email"]).first()
            if existing_user:
                return (
                    jsonify(
                        {
                            "success": False,
                            "error": "User Already Exists",
                            "message": "A user with this email address already exists.",
                        }
                    ),
                    409,
                )

            # Create new user
            user = auth_service.create_user(
                email=data["email"], password=data["password"]
            )

            # Create audit log
            audit_service.log_event(
                event_type=AuditEventType.USER_REGISTRATION,
                event_description=f"New user registered: {user.email}",
                user_id=user.id,
                ip_address=request.remote_addr,
                user_agent=request.headers.get("User-Agent"),
            )

            return (
                jsonify(
                    {
                        "success": True,
                        "message": "User registered successfully",
                        "user": user.to_dict(),
                    }
                ),
                201,
            )

        except Exception as e:
            app.logger.error(f"Registration error: {e}")
            return (
                jsonify(
                    {
                        "success": False,
                        "error": "Registration Failed",
                        "message": str(e),
                    }
                ),
                400,
            )

    @app.route("/api/auth/login", methods=["POST"])
    @limiter.limit(app.config["RATELIMIT_LOGIN"])
    def login():
        """User login endpoint"""
        try:
            # Validate request data
            schema = UserLoginSchema()
            data = schema.load(request.json)

            # Authenticate user
            user = auth_service.authenticate_user(
                email=data["email"],
                password=data["password"],
                ip_address=request.remote_addr,
                user_agent=request.headers.get("User-Agent"),
            )

            if not user:
                # Create audit log for failed login
                audit_service.log_event(
                    event_type=AuditEventType.USER_LOGIN,
                    event_description=f"Failed login attempt for email: {data['email']}",
                    severity=AuditSeverity.MEDIUM,
                    ip_address=request.remote_addr,
                    user_agent=request.headers.get("User-Agent"),
                )

                return (
                    jsonify(
                        {
                            "success": False,
                            "error": "Authentication Failed",
                            "message": "Invalid email or password.",
                        }
                    ),
                    401,
                )

            # Check if account is locked
            if user.is_locked():
                return (
                    jsonify(
                        {
                            "success": False,
                            "error": "Account Locked",
                            "message": "Account is temporarily locked due to multiple failed login attempts.",
                        }
                    ),
                    423,
                )

            # Create JWT tokens
            access_token = create_access_token(identity=user.id)
            refresh_token = create_refresh_token(identity=user.id)

            # Create user session
            session = auth_service.create_session(
                user_id=user.id,
                access_token=access_token,
                refresh_token=refresh_token,
                ip_address=request.remote_addr,
                user_agent=request.headers.get("User-Agent"),
            )

            # Update last login
            user.last_login = datetime.now(timezone.utc)
            user.failed_login_attempts = 0
            user.locked_until = None
            db.session.commit()

            # Create audit log
            audit_service.log_event(
                event_type=AuditEventType.USER_LOGIN,
                event_description=f"User logged in: {user.email}",
                user_id=user.id,
                ip_address=request.remote_addr,
                user_agent=request.headers.get("User-Agent"),
            )

            return (
                jsonify(
                    {
                        "success": True,
                        "message": "Login successful",
                        "user": user.to_dict(),
                        "tokens": {
                            "access_token": access_token,
                            "refresh_token": refresh_token,
                        },
                    }
                ),
                200,
            )

        except Exception as e:
            app.logger.error(f"Login error: {e}")
            return (
                jsonify(
                    {
                        "success": False,
                        "error": "Login Failed",
                        "message": "An error occurred during login.",
                    }
                ),
                500,
            )

    @app.route("/api/auth/logout", methods=["POST"])
    @jwt_required()
    def logout():
        """User logout endpoint"""
        try:
            user_id = get_jwt_identity()
            jti = get_jwt()["jti"]

            # Add token to blacklist
            blacklisted_tokens.add(jti)

            # Revoke user session
            auth_service.revoke_session(user_id)

            # Create audit log
            audit_service.log_event(
                event_type=AuditEventType.USER_LOGOUT,
                event_description="User logged out",
                user_id=user_id,
                ip_address=request.remote_addr,
                user_agent=request.headers.get("User-Agent"),
            )

            return jsonify({"success": True, "message": "Logout successful"}), 200

        except Exception as e:
            app.logger.error(f"Logout error: {e}")
            return (
                jsonify(
                    {
                        "success": False,
                        "error": "Logout Failed",
                        "message": "An error occurred during logout.",
                    }
                ),
                500,
            )

    # Credit scoring endpoints
    @app.route("/api/credit/calculate-score", methods=["POST"])
    @jwt_required()
    @limiter.limit("10 per minute")
    def calculate_credit_score():
        """Calculate credit score endpoint"""
        try:
            user_id = get_jwt_identity()
            data = request.json or {}

            # Get wallet address from request or user profile
            wallet_address = data.get("walletAddress")
            if not wallet_address:
                user = User.query.get(user_id)
                if user and user.profile:
                    wallet_address = user.profile.wallet_address

            if not wallet_address:
                return (
                    jsonify(
                        {
                            "success": False,
                            "error": "Wallet Address Required",
                            "message": "Wallet address is required for credit score calculation.",
                        }
                    ),
                    400,
                )

            # Calculate credit score
            result = credit_service.calculate_credit_score(
                user_id=user_id,
                wallet_address=wallet_address,
                force_recalculation=data.get("force_recalculation", False),
            )

            # Create audit log
            audit_service.log_event(
                event_type=AuditEventType.CREDIT_SCORE_CALCULATION,
                event_description=f"Credit score calculated for user: {user_id}",
                user_id=user_id,
                resource_type="credit_score",
                resource_id=result.get("credit_score_id"),
                event_data={
                    "wallet_address": wallet_address,
                    "score": result.get("score"),
                    "model_version": result.get("model_version"),
                },
            )

            return jsonify({"success": True, "data": result}), 200

        except Exception as e:
            app.logger.error(f"Credit score calculation error: {e}")
            return (
                jsonify(
                    {
                        "success": False,
                        "error": "Calculation Failed",
                        "message": "An error occurred during credit score calculation.",
                    }
                ),
                500,
            )

    @app.route("/api/credit/history", methods=["GET"])
    @jwt_required()
    def get_credit_history():
        """Get credit history endpoint"""
        try:
            user_id = get_jwt_identity()

            # Get query parameters
            page = request.args.get("page", 1, type=int)
            per_page = min(request.args.get("per_page", 20, type=int), 100)

            # Get credit history
            history = (
                CreditHistory.query.filter_by(user_id=user_id)
                .order_by(CreditHistory.event_date.desc())
                .paginate(page=page, per_page=per_page, error_out=False)
            )

            return (
                jsonify(
                    {
                        "success": True,
                        "data": {
                            "history": [event.to_dict() for event in history.items],
                            "pagination": {
                                "page": page,
                                "per_page": per_page,
                                "total": history.total,
                                "pages": history.pages,
                                "has_next": history.has_next,
                                "has_prev": history.has_prev,
                            },
                        },
                    }
                ),
                200,
            )

        except Exception as e:
            app.logger.error(f"Credit history error: {e}")
            return (
                jsonify(
                    {
                        "success": False,
                        "error": "History Retrieval Failed",
                        "message": "An error occurred while retrieving credit history.",
                    }
                ),
                500,
            )

    # Loan management endpoints
    @app.route("/api/loans/apply", methods=["POST"])
    @jwt_required()
    @limiter.limit("3 per hour")
    def apply_for_loan():
        """Loan application endpoint"""
        try:
            user_id = get_jwt_identity()

            # Validate request data
            schema = LoanApplicationSchema()
            data = schema.load(request.json)

            # Create loan application
            application = LoanApplication(
                user_id=user_id,
                application_number=LoanApplication().generate_application_number(),
                loan_type=data["loan_type"],
                requested_amount=data["requested_amount"],
                requested_term_months=data["requested_term_months"],
                requested_rate=data.get("requested_rate"),
                status=LoanStatus.SUBMITTED,
                submitted_at=datetime.now(timezone.utc),
            )

            # Set application data
            application.set_application_data(data.get("application_data", {}))

            # Get current credit score
            current_score = (
                CreditScore.query.filter_by(user_id=user_id)
                .order_by(CreditScore.calculated_at.desc())
                .first()
            )

            if current_score:
                application.credit_score_at_application = current_score.score

            # Calculate approval probability (simplified)
            if current_score:
                base_probability = (current_score.score - 300) / 550
                amount_factor = max(0, 1 - (float(data["requested_amount"]) / 50000))
                application.approval_probability = min(
                    100, (base_probability * 0.7 + amount_factor * 0.3) * 100
                )

            db.session.add(application)
            db.session.commit()

            # Create audit log
            audit_service.log_event(
                event_type=AuditEventType.LOAN_APPLICATION,
                event_description=f"Loan application submitted: {application.application_number}",
                user_id=user_id,
                resource_type="loan_application",
                resource_id=application.id,
                event_data={
                    "application_number": application.application_number,
                    "loan_type": data["loan_type"],
                    "requested_amount": float(data["requested_amount"]),
                },
            )

            return (
                jsonify(
                    {
                        "success": True,
                        "message": "Loan application submitted successfully",
                        "data": application.to_dict(),
                    }
                ),
                201,
            )

        except Exception as e:
            app.logger.error(f"Loan application error: {e}")
            return (
                jsonify(
                    {
                        "success": False,
                        "error": "Application Failed",
                        "message": "An error occurred while processing the loan application.",
                    }
                ),
                500,
            )

    @app.route("/api/loans/calculate", methods=["POST"])
    @jwt_required()
    def calculate_loan_terms():
        """Calculate loan terms endpoint"""
        try:
            user_id = get_jwt_identity()
            data = request.json or {}

            amount = float(data.get("amount", 1000))
            rate = float(data.get("rate", 5.0))
            term_months = int(data.get("term_months", 36))

            # Get current credit score
            current_score = (
                CreditScore.query.filter_by(user_id=user_id)
                .order_by(CreditScore.calculated_at.desc())
                .first()
            )

            credit_score = current_score.score if current_score else 300

            # Calculate loan terms
            monthly_rate = rate / 100 / 12
            if monthly_rate > 0:
                monthly_payment = (
                    amount * monthly_rate * ((1 + monthly_rate) ** term_months)
                ) / (((1 + monthly_rate) ** term_months) - 1)
            else:
                monthly_payment = amount / term_months

            total_payment = monthly_payment * term_months
            total_interest = total_payment - amount

            # Calculate approval probability
            base_probability = (credit_score - 300) / 550
            amount_factor = max(0, 1 - (amount / 50000))
            rate_factor = min(1, rate / 15)

            approval_probability = (
                (base_probability * 0.6) + (amount_factor * 0.2) + (rate_factor * 0.2)
            )
            approval_probability = max(0, min(approval_probability, 1)) * 100

            return (
                jsonify(
                    {
                        "success": True,
                        "data": {
                            "loan_amount": amount,
                            "interest_rate": rate,
                            "term_months": term_months,
                            "monthly_payment": round(monthly_payment, 2),
                            "total_payment": round(total_payment, 2),
                            "total_interest": round(total_interest, 2),
                            "approval_probability": round(approval_probability, 2),
                            "credit_score": credit_score,
                        },
                    }
                ),
                200,
            )

        except Exception as e:
            app.logger.error(f"Loan calculation error: {e}")
            return (
                jsonify(
                    {
                        "success": False,
                        "error": "Calculation Failed",
                        "message": "An error occurred during loan calculation.",
                    }
                ),
                500,
            )

    # User profile endpoints
    @app.route("/api/profile", methods=["GET"])
    @jwt_required()
    def get_profile():
        """Get user profile endpoint"""
        try:
            user_id = get_jwt_identity()
            user = User.query.get(user_id)

            if not user:
                return (
                    jsonify(
                        {
                            "success": False,
                            "error": "User Not Found",
                            "message": "User profile not found.",
                        }
                    ),
                    404,
                )

            profile_data = user.to_dict()
            if user.profile:
                profile_data["profile"] = user.profile.to_dict()

            return jsonify({"success": True, "data": profile_data}), 200

        except Exception as e:
            app.logger.error(f"Profile retrieval error: {e}")
            return (
                jsonify(
                    {
                        "success": False,
                        "error": "Profile Retrieval Failed",
                        "message": "An error occurred while retrieving the profile.",
                    }
                ),
                500,
            )

    # Create database tables
    with app.app_context():
        try:
            db.create_all()
            app.logger.info("Database tables created successfully")
        except Exception as e:
            app.logger.error(f"Database initialization error: {e}")

    return app


# Create application instance
app = create_app()

if __name__ == "__main__":
    # Configure logging
    logging.basicConfig(
        level=logging.INFO, format="%(asctime)s %(levelname)s %(name)s %(message)s"
    )

    # Run application
    app.run(host="0.0.0.0", port=5000, debug=True)
