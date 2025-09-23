import React from 'react';
import { Plus, Filter, CheckSquare } from 'lucide-react';
import { motion } from 'framer-motion';

const Header = ({ onCreateTask, filter, onFilterChange }) => {
  const filterOptions = [
    { value: 'all', label: 'All Tasks', count: null },
    { value: 'pending', label: 'Pending', count: null },
    { value: 'in_progress', label: 'In Progress', count: null },
    { value: 'completed', label: 'Completed', count: null },
  ];

  return (
    <div className="mb-8">
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <motion.div
          initial={{ opacity: 0, x: -20 }}
          animate={{ opacity: 1, x: 0 }}
          transition={{ duration: 0.5 }}
          className="flex items-center gap-3"
        >
          <div className="bg-primary-600 p-3 rounded-xl">
            <CheckSquare className="h-8 w-8 text-white" />
          </div>
          <div>
            <h1 className="text-3xl font-bold text-gray-900">
              Task Manager
            </h1>
            <p className="text-gray-600 mt-1">
              Organize your work and boost productivity
            </p>
          </div>
        </motion.div>

        <motion.div
          initial={{ opacity: 0, x: 20 }}
          animate={{ opacity: 1, x: 0 }}
          transition={{ duration: 0.5, delay: 0.1 }}
          className="flex items-center gap-3"
        >
          <div className="flex items-center gap-2 bg-white rounded-lg border border-gray-200 p-1">
            <Filter className="h-4 w-4 text-gray-500 ml-2" />
            <select
              value={filter}
              onChange={(e) => onFilterChange(e.target.value)}
              className="bg-transparent border-none outline-none text-sm text-gray-700 px-2 py-1"
            >
              {filterOptions.map((option) => (
                <option key={option.value} value={option.value}>
                  {option.label}
                </option>
              ))}
            </select>
          </div>

          <button
            onClick={onCreateTask}
            className="btn-primary flex items-center gap-2 shadow-lg hover:shadow-xl transform hover:scale-105 transition-all duration-200"
          >
            <Plus className="h-4 w-4" />
            Add Task
          </button>
        </motion.div>
      </div>
    </div>
  );
};

export default Header;