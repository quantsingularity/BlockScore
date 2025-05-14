module.exports = {
  transform: {
    '^.+\\.(js|jsx|ts|tsx)$': 'babel-jest',
  },
  transformIgnorePatterns: [
    '/node_modules/(?!axios)/', // Transform axios, ignore others in node_modules
  ],
  moduleNameMapper: {
    'axios': 'axios/dist/node/axios.cjs' // Force Jest to use the CJS version of axios
  }
};

