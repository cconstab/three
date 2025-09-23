import React from 'react';
import { CheckCircle, Clock, AlertCircle, BarChart3 } from 'lucide-react';
import { motion } from 'framer-motion';

const StatsCards = ({ stats }) => {
  if (!stats) return null;

  const cards = [
    {
      title: 'Total Tasks',
      value: stats.total_tasks || 0,
      icon: BarChart3,
      color: 'bg-primary-500',
      bgColor: 'bg-primary-50',
      textColor: 'text-primary-700'
    },
    {
      title: 'Completed',
      value: stats.completed_tasks || 0,
      icon: CheckCircle,
      color: 'bg-success-500',
      bgColor: 'bg-success-50',
      textColor: 'text-success-700'
    },
    {
      title: 'In Progress',
      value: stats.in_progress_tasks || 0,
      icon: Clock,
      color: 'bg-warning-500',
      bgColor: 'bg-warning-50',
      textColor: 'text-warning-700'
    },
    {
      title: 'High Priority',
      value: stats.high_priority_tasks || 0,
      icon: AlertCircle,
      color: 'bg-danger-500',
      bgColor: 'bg-danger-50',
      textColor: 'text-danger-700'
    }
  ];

  return (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
      {cards.map((card, index) => (
        <motion.div
          key={card.title}
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5, delay: index * 0.1 }}
          className={`${card.bgColor} rounded-xl p-6 border border-gray-100 hover:shadow-lg transition-all duration-300 transform hover:scale-105`}
        >
          <div className="flex items-center justify-between">
            <div>
              <p className={`text-sm font-medium ${card.textColor} opacity-80`}>
                {card.title}
              </p>
              <p className={`text-3xl font-bold ${card.textColor} mt-2`}>
                {card.value}
              </p>
            </div>
            <div className={`${card.color} p-3 rounded-lg`}>
              <card.icon className="h-6 w-6 text-white" />
            </div>
          </div>
          
          {/* Progress indicator */}
          {card.title === 'Completed' && stats.total_tasks > 0 && (
            <div className="mt-4">
              <div className="bg-white rounded-full h-2 overflow-hidden">
                <motion.div
                  initial={{ width: 0 }}
                  animate={{ 
                    width: `${(stats.completed_tasks / stats.total_tasks) * 100}%` 
                  }}
                  transition={{ duration: 1, delay: 0.5 }}
                  className="h-full bg-success-500"
                />
              </div>
              <p className="text-xs text-success-600 mt-1">
                {Math.round((stats.completed_tasks / stats.total_tasks) * 100)}% Complete
              </p>
            </div>
          )}
        </motion.div>
      ))}
    </div>
  );
};

export default StatsCards;