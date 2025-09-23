import React from 'react';
import TaskCard from './TaskCard';
import { motion } from 'framer-motion';

const TaskBoard = ({ tasks, onEditTask, onTaskDeleted }) => {
  const columns = [
    { 
      id: 'pending', 
      title: 'Pending', 
      color: 'border-warning-200 bg-warning-50',
      headerColor: 'bg-warning-500'
    },
    { 
      id: 'in_progress', 
      title: 'In Progress', 
      color: 'border-primary-200 bg-primary-50',
      headerColor: 'bg-primary-500'
    },
    { 
      id: 'completed', 
      title: 'Completed', 
      color: 'border-success-200 bg-success-50',
      headerColor: 'bg-success-500'
    }
  ];

  const getTasksByStatus = (status) => {
    return tasks.filter(task => task.status === status);
  };

  return (
    <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
      {columns.map((column, columnIndex) => {
        const columnTasks = getTasksByStatus(column.id);
        
        return (
          <motion.div
            key={column.id}
            initial={{ opacity: 0, x: -20 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ duration: 0.5, delay: columnIndex * 0.1 }}
            className={`${column.color} rounded-xl border-2 border-dashed min-h-[500px]`}
          >
            <div className={`${column.headerColor} text-white p-4 rounded-t-xl flex items-center justify-between`}>
              <h3 className="font-semibold text-lg">{column.title}</h3>
              <span className="bg-white bg-opacity-20 px-2 py-1 rounded-full text-sm font-medium">
                {columnTasks.length}
              </span>
            </div>
            
            <div className="p-4 space-y-4">
              {columnTasks.length === 0 ? (
                <motion.div
                  initial={{ opacity: 0 }}
                  animate={{ opacity: 1 }}
                  transition={{ delay: 0.3 }}
                  className="text-center py-8"
                >
                  <div className="text-gray-400 mb-2">
                    <svg className="mx-auto h-12 w-12" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1} d="M9 5H7a2 2 0 00-2 2v10a2 2 0 002 2h8a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
                    </svg>
                  </div>
                  <p className="text-gray-500 text-sm">No tasks in {column.title.toLowerCase()}</p>
                </motion.div>
              ) : (
                columnTasks.map((task, index) => (
                  <motion.div
                    key={task.id}
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ duration: 0.3, delay: index * 0.1 }}
                  >
                    <TaskCard
                      task={task}
                      onEdit={onEditTask}
                      onDelete={onTaskDeleted}
                    />
                  </motion.div>
                ))
              )}
            </div>
          </motion.div>
        );
      })}
    </div>
  );
};

export default TaskBoard;