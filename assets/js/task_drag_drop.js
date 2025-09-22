// Task Drag and Drop functionality
const TaskDragDrop = {
  mounted() {
    this.initDragAndDrop();
  },

  updated() {
    this.initDragAndDrop();
  },

  initDragAndDrop() {
    // Make task cards draggable
    const taskCards = this.el.querySelectorAll('[data-task-id]');
    taskCards.forEach(card => {
      card.draggable = true;
      card.addEventListener('dragstart', this.handleDragStart.bind(this));
      card.addEventListener('dragend', this.handleDragEnd.bind(this));
    });

    // Make columns droppable
    const columns = this.el.querySelectorAll('[data-column-status]');
    columns.forEach(column => {
      column.addEventListener('dragover', this.handleDragOver.bind(this));
      column.addEventListener('drop', this.handleDrop.bind(this));
      column.addEventListener('dragenter', this.handleDragEnter.bind(this));
      column.addEventListener('dragleave', this.handleDragLeave.bind(this));
    });
  },

  handleDragStart(e) {
    const taskId = e.target.getAttribute('data-task-id');
    const currentStatus = e.target.getAttribute('data-task-status');
    
    e.dataTransfer.setData('text/plain', taskId);
    e.dataTransfer.setData('application/json', JSON.stringify({
      taskId: taskId,
      currentStatus: currentStatus
    }));
    
    e.target.style.opacity = '0.5';
    e.target.classList.add('dragging');
  },

  handleDragEnd(e) {
    e.target.style.opacity = '1';
    e.target.classList.remove('dragging');
    
    // Remove drag indicators from all columns
    const columns = this.el.querySelectorAll('[data-column-status]');
    columns.forEach(col => col.classList.remove('drag-over'));
  },

  handleDragOver(e) {
    e.preventDefault();
    e.dataTransfer.dropEffect = 'move';
  },

  handleDragEnter(e) {
    e.preventDefault();
    const column = e.target.closest('[data-column-status]');
    if (column) {
      column.classList.add('drag-over');
    }
  },

  handleDragLeave(e) {
    const column = e.target.closest('[data-column-status]');
    const rect = column.getBoundingClientRect();
    
    // Only remove the class if we're actually leaving the column
    if (e.clientX < rect.left || e.clientX > rect.right || 
        e.clientY < rect.top || e.clientY > rect.bottom) {
      column.classList.remove('drag-over');
    }
  },

  handleDrop(e) {
    e.preventDefault();
    
    const column = e.target.closest('[data-column-status]');
    const newStatus = column.getAttribute('data-column-status');
    
    try {
      const data = JSON.parse(e.dataTransfer.getData('application/json'));
      const { taskId, currentStatus } = data;
      
      // Don't do anything if dropping in the same column
      if (currentStatus === newStatus) {
        column.classList.remove('drag-over');
        return;
      }
      
      // Update task status
      this.pushEvent('move_task', { 
        task_id: parseInt(taskId), 
        new_status: newStatus 
      });
      
    } catch (error) {
      console.error('Error handling drop:', error);
    }
    
    column.classList.remove('drag-over');
  }
};

export { TaskDragDrop };