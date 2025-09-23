import React, { useState } from 'react';
import { Edit3, Trash2, Calendar, Flag } from 'lucide-react';
import { format, isAfter, isBefore } from 'date-fns';
import { motion } from 'framer-motion';
import { taskService } from '../services/taskService';

const TaskCard = ({ task, onEdit, onDelete }) => {
  const [isDeleting, setIsDeleting] = useState(false);

  const handleDelete = async () => {
    if (window.confirm('Are you sure you want to delete this task?')) {
      setIsDeleting(true);
      try {
        await taskService.deleteTask(task.id);
        onDelete();
      } catch (error) {
        console.error('Error deleting task:', error);
      } finally {
        setIsDeleting(false);
      }
    }
  };

  const getStatusBadge = (status) => {
    const badges = {
      pending: 'badge-pending',
      in_progress: 'badge-in-progress',
      completed: 'badge-completed'
    };
    return badges[status] || 'badge-pending';
  };

  const getPriorityBadge = (priority) => {
    const badges = {
      low: 'badge-low',
      medium: 'badge-medium',
      high: 'badge-high'
    };
    return badges[priority] || 'badge-medium';
  };

  const getPriorityColor = (priority) => {
    const colors = {
      low: 'text-gray-500',
      medium: 'text-warning-500',
      high: 'text-danger-500'
    };
    return colors[priority] || 'text-gray-500';
  };

  const isOverdue = task.due_date && 
    isBefore(new Date(task.due_date), new Date()) && 
    task.status !== 'completed';

  const formatDueDate = (dateString) => {
    if (!dateString) return null;
    try {
      return format(new Date(dateString), 'MMM dd, yyyy');
    } catch (error) {
      return null;
    }
  };

  return (
    <motion.div
      layout
      initial={{ opacity: 0, scale: 0.9 }}
      animate={{ opacity: 1, scale: 1 }}
      exit={{ opacity: 0, scale: 0.9 }}
      whileHover={{ y: -2 }}
      className={`card hover:shadow-md transition-all duration-200 ${
        isOverdue ? 'border-l-4 border-l-danger-500' : ''
      }`}
    >
      {/* Header */}
      <div className="flex items-start justify-between mb-3">
        <div className="flex-1">
          <h4 className="font-semibold text-gray-900 mb-2 line-clamp-2">
            {task.title}
          </h4>
          <div className="flex flex-wrap gap-2">
            <span className={`badge ${getStatusBadge(task.status)}`}>
              {task.status.replace('_', ' ')}
            </span>
            <span className={`badge ${getPriorityBadge(task.priority)} flex items-center gap-1`}>
              <Flag className={`h-3 w-3 ${getPriorityColor(task.priority)}`} />
              {task.priority}
            </span>
          </div>
        </div>
        
        <div className="flex items-center gap-1 ml-2">
          <motion.button
            whileHover={{ scale: 1.1 }}
            whileTap={{ scale: 0.9 }}
            onClick={() => onEdit(task)}
            className="p-1.5 text-gray-400 hover:text-primary-600 hover:bg-primary-50 rounded-lg transition-colors"
            title="Edit task"
          >
            <Edit3 className="h-4 w-4" />
          </motion.button>
          <motion.button
            whileHover={{ scale: 1.1 }}
            whileTap={{ scale: 0.9 }}
            onClick={handleDelete}
            disabled={isDeleting}
            className="p-1.5 text-gray-400 hover:text-danger-600 hover:bg-danger-50 rounded-lg transition-colors disabled:opacity-50"
            title="Delete task"
          >
            <Trash2 className="h-4 w-4" />
          </motion.button>
        </div>
      </div>

      {/* Description */}
      {task.description && (
        <p className="text-gray-600 text-sm mb-3 line-clamp-3">
          {task.description}
        </p>
      )}

      {/* Due Date */}
      {task.due_date && (
        <div className="flex items-center gap-2 text-sm">
          <Calendar className="h-4 w-4 text-gray-400" />
          <span className={`${
            isOverdue 
              ? 'text-danger-600 font-medium' 
              : 'text-gray-600'
          }`}>
            {formatDueDate(task.due_date)}
            {isOverdue && (
              <span className="ml-1 text-xs bg-danger-100 text-danger-700 px-1.5 py-0.5 rounded">
                Overdue
              </span>
            )}
          </span>
        </div>
      )}

      {/* Created Date */}
      <div className="mt-3 pt-3 border-t border-gray-100">
        <p className="text-xs text-gray-400">
          Created {format(new Date(task.created_at), 'MMM dd, yyyy')}
        </p>
      </div>
    </motion.div>
  );
};

export default TaskCard;