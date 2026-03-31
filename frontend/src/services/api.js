import axios from "axios";

// NEXT_PUBLIC_API_URL must be set at build time (e.g. http://<appgw-ip>).
// Falls back to empty string so calls use relative URLs in production,
// keeping the build functional behind any reverse proxy or AppGateway.
const API_URL = process.env.NEXT_PUBLIC_API_URL || "";

// General function to handle errors
const handleApiError = (error, defaultMessage) => {
  return error.response?.data?.message || defaultMessage;
};

// ---------------------- User Authentication ----------------------

export const registerUser = async (userData) => {
  try {
    const response = await axios.post(`${API_URL}/api/users/register`, userData);
    return response.data;
  } catch (error) {
    throw new Error(handleApiError(error, "Registration failed"));
  }
};

export const loginUser = async (userData) => {
  try {
    const response = await axios.post(`${API_URL}/api/users/login`, userData);
    return response.data;
  } catch (error) {
    throw new Error(handleApiError(error, "Login failed"));
  }
};

// ---------------------- Books ----------------------

export const fetchBooks = async () => {
  try {
    const response = await axios.get(`${API_URL}/api/books`);
    return response.data;
  } catch (error) {
    throw new Error(handleApiError(error, "Failed to fetch books"));
  }
};

export const fetchBookDetails = async (bookId) => {
  try {
    const response = await axios.get(`${API_URL}/api/books/${bookId}`);
    return response.data;
  } catch (error) {
    throw new Error(handleApiError(error, "Failed to fetch book details"));
  }
};

// ---------------------- Reviews ----------------------

export const fetchReviews = async (bookId) => {
  try {
    const response = await axios.get(`${API_URL}/api/reviews/${bookId}`);
    return response.data;
  } catch (error) {
    throw new Error(handleApiError(error, "Failed to fetch reviews"));
  }
};

export const submitReview = async (reviewData, token) => {
  try {
    const response = await axios.post(`${API_URL}/api/reviews`, reviewData, {
      headers: { Authorization: `Bearer ${token}` },
    });
    return response.data;
  } catch (error) {
    throw new Error(handleApiError(error, "Failed to submit review"));
  }
};

// ---------------------- Authentication Token ----------------------

export const setAuthToken = (token) => {
  if (token) {
    localStorage.setItem("token", token);
  } else {
    localStorage.removeItem("token");
  }
};

// Attach token to Axios requests dynamically
axios.interceptors.request.use((config) => {
  const token = localStorage.getItem("token");
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});
