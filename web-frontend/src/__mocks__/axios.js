export default {
  get: jest.fn(() => Promise.resolve({ data: {} })),
  post: jest.fn(() => Promise.resolve({ data: {} })),
  create: jest.fn(function () {
    return this;
  }),
  // Add other methods as needed by your application
};
