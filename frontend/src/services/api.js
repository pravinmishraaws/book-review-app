import axios from "axios";

// Ensure API_URL does NOT contain `/api`
const API_URL = process.env.NEXT_PUBLIC_API_URL || "http://localhost:3001";

// General function to handle errors
const handleApiError = (error, defaultMessage) => {
  return error.response?.data?.message || defaultMessage;
};

// ---------------------- User Authentication ----------------------

export const registerUser = async (userData) => {
  try {
    const response = await axios.post(`${API_URL}/users/register`, userData);
    return response.data;
  } catch (error) {
    throw new Error(handleApiError(error, "Registration failed"));
  }
};

export const loginUser = async (userData) => {
  try {
    const response = await axios.post(`${API_URL}/users/login`, userData);
    return response.data;
  } catch (error) {
    throw new Error(handleApiError(error, "Login failed"));
  }
};

// ---------------------- Books ----------------------

export const fetchBooks = async () => {
  try {
    const response = await axios.get(`${API_URL}/books`);
    return response.data;
  } catch (error) {
    throw new Error(handleApiError(error, "Failed to fetch books"));
  }
};

export const fetchBookDetails = async (bookId) => {
  try {
    const response = await axios.get(`${API_URL}/books/${bookId}`);
    return response.data;
  } catch (error) {
    throw new Error(handleApiError(error, "Failed to fetch book details"));
  }
};

// ---------------------- Reviews ----------------------

export const fetchReviews = async (bookId) => {
  try {
    const response = await axios.get(`${API_URL}/reviews/${bookId}`);
    return response.data;
  } catch (error) {
    throw new Error(handleApiError(error, "Failed to fetch reviews"));
  }
};

export const submitReview = async (reviewData, token) => {
  try {
    const response = await axios.post(`${API_URL}/reviews`, reviewData, {
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
