import axios from 'axios';
import toast from 'react-hot-toast';

const API_URL = process.env.REACT_APP_API_URL || 'http://localhost:3001';

const api = axios.create({
  baseURL: API_URL,
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Add response interceptor for error handling
api.interceptors.response.use(
  (response) => response,
  (error) => {
    const message = error.response?.data?.message || error.message || 'An error occurred';
    toast.error(message);
    return Promise.reject(error);
  }
);

export const taskService = {
  // Get all tasks
  async getTasks(filters = {}) {
    try {
      const params = new URLSearchParams();
      if (filters.status) params.append('status', filters.status);
      if (filters.priority) params.append('priority', filters.priority);
      
      const response = await api.get(`/api/tasks?${params}`);
      return response.data.data;
    } catch (error) {
      console.error('Error fetching tasks:', error);
      throw error;
    }
  },

  // Get single task
  async getTask(id) {
    try {
      const response = await api.get(`/api/tasks/${id}`);
      return response.data.data;
    } catch (error) {
      console.error('Error fetching task:', error);
      throw error;
    }
  },

  // Create new task
  async createTask(taskData) {
    try {
      const response = await api.post('/api/tasks', taskData);
      toast.success('Task created successfully!');
      return response.data.data;
    } catch (error) {
      console.error('Error creating task:', error);
      throw error;
    }
  },

  // Update task
  async updateTask(id, taskData) {
    try {
      const response = await api.put(`/api/tasks/${id}`, taskData);
      toast.success('Task updated successfully!');
      return response.data.data;
    } catch (error) {
      console.error('Error updating task:', error);
      throw error;
    }
  },

  // Delete task
  async deleteTask(id) {
    try {
      await api.delete(`/api/tasks/${id}`);
      toast.success('Task deleted successfully!');
      return true;
    } catch (error) {
      console.error('Error deleting task:', error);
      throw error;
    }
  },

  // Get statistics
  async getStats() {
    try {
      const response = await api.get('/api/stats');
      return response.data.data;
    } catch (error) {
      console.error('Error fetching stats:', error);
      throw error;
    }
  },

  // Health check
  async healthCheck() {
    try {
      const response = await api.get('/health');
      return response.data;
    } catch (error) {
      console.error('Health check failed:', error);
      throw error;
    }
  }
};