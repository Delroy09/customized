// Create context menu element
const contextMenu = document.createElement('div');
contextMenu.id = 'context-menu';
contextMenu.style.display = 'none';
contextMenu.style.position = 'absolute';
contextMenu.style.background = '#fff';
contextMenu.style.border = '1px solid #ccc';
contextMenu.style.boxShadow = '0 2px 5px rgba(0, 0, 0, 0.2)';

// Add menu options
contextMenu.innerHTML = `
  <button id="delete-cell">Delete</button>
  <button id="disable-cell">Disable</button>
  <button id="enable-cell">Enable</button>
`;
document.body.appendChild(contextMenu);

// Track selected cell for context operations
let selectedCell = null;

// Add right-click handler to all data cells
document.querySelectorAll('td[data-cell]').forEach(cell => {
  cell.addEventListener('contextmenu', function(event) {
    event.preventDefault();
    selectedCell = event.target;

    // Position context menu at click location
    const rect = selectedCell.getBoundingClientRect();
    contextMenu.style.top = `${rect.bottom + window.scrollY}px`;
    contextMenu.style.left = `${rect.left + window.scrollX}px`;
    contextMenu.style.display = 'block';
  });
});

// Hide context menu when clicking outside
document.addEventListener('click', (event) => {
  if (!contextMenu.contains(event.target)) {
    contextMenu.style.display = 'none';
  }
});

// Delete action with reset for disabled cells
document.getElementById('delete-cell').addEventListener('click', () => {
    if (selectedCell && selectedCell.innerHTML.trim() !== '') {
      selectedCell.innerHTML = '';  // Clear the content
      if (selectedCell.classList.contains('disabled')) {
        selectedCell.style.backgroundColor = '';  // Reset the background color
        selectedCell.classList.remove('disabled');  // Remove the 'disabled' class
      }
    }
    contextMenu.style.display = 'none';
  });
  

// Disable action
document.getElementById('disable-cell').addEventListener('click', () => {
  if (selectedCell && selectedCell.innerHTML.trim() !== '') {
    selectedCell.style.backgroundColor = '#d3d3d3'; // Greyed out
    selectedCell.classList.add('disabled');
  }
  contextMenu.style.display = 'none';
});

// Enable action
document.getElementById('enable-cell').addEventListener('click', () => {
  if (selectedCell && selectedCell.classList.contains('disabled')) {
    selectedCell.style.backgroundColor = ''; // Reset to original color
    selectedCell.classList.remove('disabled');
  }
  contextMenu.style.display = 'none';
});




// Function to reset all disabled cells
function resetDisabledCells() {
    document.querySelectorAll('td[data-cell].disabled').forEach(cell => {
      cell.style.backgroundColor = '';  // Restore original color
      cell.classList.remove('disabled');  // Remove 'disabled' class
    });
  }
  
  // Generate Timetable button
  document.querySelector('[data-btn]').addEventListener('click', () => {
    resetDisabledCells();  // Restore cells before generating
    // Your existing code for generating the timetable...
  });
  
  // Clear Timetable button
  document.querySelector('[data-clear]').addEventListener('click', () => {
    resetDisabledCells();  // Restore cells before clearing
    document.querySelectorAll('td[data-cell]').forEach(cell => {
      cell.innerHTML = '';  // Clear all cell contents
    });
  });