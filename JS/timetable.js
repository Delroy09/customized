document.addEventListener('DOMContentLoaded', () => {
    const cells = document.querySelectorAll('.timetable td:not(:first-child):not(.recess)');
    let dragSrc = null;

    // Add conflict detection function
    function checkTeacherConflicts(table) {
        // First set table properties
        table.style.cssText = `
            border-collapse: separate !important;
            border-spacing: 1px !important;
        `;
        
        // Reset all cell styles with individual borders
        table.querySelectorAll('td').forEach(cell => {
            cell.style.cssText = `
                box-sizing: border-box !important;
                border-top: 2.5px solid #ccc !important;
                border-bottom: 2.5px solid #ccc !important;
                border-left: 2.5px solid #ccc !important;
                border-right: 2.5px solid #ccc !important;
                margin: 1px !important;
                padding: 8px !important;
                position: relative !important;
            `;
        });
        
        const columnCount = table.rows[0].cells.length;
        
        // Check each column
        for (let col = 1; col < columnCount; col++) {
            if (table.rows[0].cells[col].classList.contains('recess')) continue;
            
            const teachersInTimeSlot = new Map();
            
            // Check each row in column
            for (let row = 1; row < table.rows.length; row++) {
                const cell = table.rows[row].cells[col];
                const teacherSpan = cell.querySelector('.teacher-initial');
                
                if (teacherSpan && teacherSpan.textContent) {
                    const teacher = teacherSpan.textContent.replace(/[()]/g, '').trim();
                    if (teacher !== '-') {
                        if (!teachersInTimeSlot.has(teacher)) {
                            teachersInTimeSlot.set(teacher, []);
                        }
                        teachersInTimeSlot.get(teacher).push(cell);
                    }
                }
            }
            
            // Highlight conflicts with individual borders
            teachersInTimeSlot.forEach((cells, teacher) => {
                if (cells.length > 1) {
                    cells.forEach(cell => {
                        cell.style.cssText = `
                            box-sizing: border-box !important;
                            border-top: 3px solid #fc6358 !important;
                            border-bottom: 3px solid #fc6358 !important;
                            border-left: 3px solid #fc6358 !important;
                            border-right: 3px solid #fc6358 !important;
                            margin: 1px !important;
                            padding: 8px !important;
                            position: relative !important;
                        `;
                    });
                }
            });
        }
    }

    // Modify cell event listeners to include conflict check
    cells.forEach(cell => {
        cell.setAttribute('draggable', true);
        
        cell.addEventListener('dragstart', (e) => {
            dragSrc = cell;
            cell.classList.add('dragging');
        });

        cell.addEventListener('dragend', () => {
            dragSrc.classList.remove('dragging');
            // Check conflicts after drag ends
            checkTeacherConflicts(dragSrc.closest('table'));
        });

        cell.addEventListener('dragover', (e) => {
            e.preventDefault();
            cell.classList.add('drag-over');
        });

        cell.addEventListener('dragleave', () => {
            cell.classList.remove('drag-over');
        });

        cell.addEventListener('drop', (e) => {
            e.preventDefault();
            cell.classList.remove('drag-over');
            
            if (dragSrc !== cell) {
                const temp = dragSrc.innerHTML;
                dragSrc.innerHTML = cell.innerHTML;
                cell.innerHTML = temp;
                
                // Check conflicts after drop
                const tables = new Set([
                    dragSrc.closest('table'),
                    cell.closest('table')
                ]);
                tables.forEach(table => checkTeacherConflicts(table));
            }
        });
    });

    // Add observer for real-time updates
    const observer = new MutationObserver((mutations) => {
        const tables = new Set();
        mutations.forEach(mutation => {
            const table = mutation.target.closest('table');
            if (table) tables.add(table);
        });
        tables.forEach(table => checkTeacherConflicts(table));
    });

    // Observe all timetables
    document.querySelectorAll('.timetable').forEach(table => {
        observer.observe(table, {
            childList: true,
            subtree: true,
            characterData: true
        });
        // Initial conflict check
        checkTeacherConflicts(table);
    });

    // Go to Top Button functionality
    window.onscroll = function() {
        const goToTopButton = document.getElementById("goToTop");
        if (document.body.scrollTop > 500 || document.documentElement.scrollTop > 500) {
            goToTopButton.style.display = "block";
        } else {
            goToTopButton.style.display = "none";
        }
    };

    document.getElementById("goToTop").onclick = function() {
        window.scrollTo({
            top: 0,
            behavior: "smooth"
        });
    };

    // Create context menu element
    const contextMenu = document.createElement('div');
    contextMenu.className = 'context-menu';
    contextMenu.innerHTML = '<button id="delete-cell">Delete</button>';
    document.body.appendChild(contextMenu);

    // Handle context menu display
    document.addEventListener('contextmenu', (e) => {
        const cell = e.target.closest('td');
        if (!cell) return;

        // Check if cell is protected (first cell, recess, or empty)
        if (cell.cellIndex === 0 || 
            cell.classList.contains('recess') || 
            !cell.textContent.trim() || 
            cell.parentElement.rowIndex === 0) {
            return;
        }

        e.preventDefault();
        
        // Position context menu
        contextMenu.style.display = 'block';
        contextMenu.style.left = `${e.pageX}px`;
        contextMenu.style.top = `${e.pageY}px`;
        
        // Store reference to current cell and its table
        contextMenu.dataset.targetCell = `${cell.parentElement.rowIndex},${cell.cellIndex}`;
        contextMenu.targetTable = cell.closest('.timetable');
    });

    // Hide context menu when clicking elsewhere
    document.addEventListener('click', (e) => {
        if (!contextMenu.contains(e.target)) {
            contextMenu.style.display = 'none';
        }
    });

    // Handle delete action
    document.getElementById('delete-cell').addEventListener('click', () => {
        const [rowIndex, cellIndex] = contextMenu.dataset.targetCell.split(',');
        const table = contextMenu.targetTable;
        const cell = table.rows[rowIndex].cells[cellIndex];
        
        // Clear cell content
        cell.innerHTML = '-';
        
        // Hide context menu
        contextMenu.style.display = 'none';
        
        // Force immediate autosave
        const autosaveInstance = table.autosaveInstance;
        if (autosaveInstance) {
            setTimeout(() => {
                autosaveInstance.saveLayout();
            }, 0);
        }
        
        // Check for conflicts after deletion
        checkTeacherConflicts(table);
    });
});


function printAllTimetables() {
    const printButtons = document.querySelector(".print-buttons");
    const backButton = document.getElementById("back");
    const resetButton = document.querySelector(".reset-layout-btn");

    // Hide elements before printing
    printButtons.style.display = "none";
    backButton.style.display = "none";
    if (resetButton) resetButton.style.display = "none";

    // Hide conflicts before printing
    handlePrintStyles('hide');

    window.print();

    // Restore conflicts after printing
    handlePrintStyles('restore');

    // Show elements after printing
    printButtons.style.display = "block";
    backButton.style.display = "block";
    if (resetButton) resetButton.style.display = "block";
}

function printDay(day) {
    const printButtons = document.querySelector(".print-buttons");
    const backButton = document.getElementById("back");
    const resetButton = document.querySelector(".reset-layout-btn");
    const allTimetables = document.querySelectorAll(".timetable");
    const allDayHeaders = document.querySelectorAll("h2");
    const allSeparators = document.querySelectorAll(".day-separator");

    // Hide all tables except selected day
    allTimetables.forEach(table => table.style.display = "none");
    allDayHeaders.forEach(header => header.style.display = "none");
    allSeparators.forEach(separator => separator.style.display = "none");
    printButtons.style.display = "none";
    backButton.style.display = "none";
    if (resetButton) resetButton.style.display = "none";

    // Show only selected day
    const selectedHeader = [...allDayHeaders].find(header => header.textContent.trim() === day);
    const selectedTable = selectedHeader?.nextElementSibling;
    
    if (selectedHeader && selectedTable) {
        selectedHeader.style.display = "block";
        selectedTable.style.display = "table";
    }

    // Hide conflicts before printing
    handlePrintStyles('hide');

    window.print();

    // Restore conflicts after printing
    handlePrintStyles('restore');

    // Restore all elements
    allTimetables.forEach(table => table.style.display = "table");
    allDayHeaders.forEach(header => header.style.display = "block");
    allSeparators.forEach(separator => separator.style.display = "block");
    printButtons.style.display = "block";
    backButton.style.display = "block";
    if (resetButton) resetButton.style.display = "block";
}

function checkTeacherConflicts(table) {
    // Preserve existing table styling
    table.style.cssText = `
        border-collapse: separate !important;
        border-spacing: 1px !important;
    `;

    // Reset all cells to default state first
    table.querySelectorAll('td').forEach(cell => {
        cell.style.cssText = `
            box-sizing: border-box !important;
            border: 2.5px solid #ccc !important;
            margin: 1px !important;
            padding: 8px !important;
            position: relative !important;
        `;
    });

    // Check conflicts column by column
    const columnCount = table.rows[0].cells.length;
    
    for (let col = 1; col < columnCount; col++) {
        // Skip recess columns
        if (table.rows[0].cells[col].classList.contains('recess')) {
            continue;
        }

        // Track teacher assignments in this time slot
        const teachersInColumn = new Map();

        // Check each cell in the column
        for (let row = 1; row < table.rows.length; row++) {
            const cell = table.rows[row].cells[col];
            const teacherSpan = cell.querySelector('.teacher-initial');
            
            if (teacherSpan && teacherSpan.textContent) {
                const teacherCode = teacherSpan.textContent.replace(/[()]/g, '').trim();
                
                // Skip empty teachers or placeholder
                if (teacherCode && teacherCode !== '-') {
                    if (!teachersInColumn.has(teacherCode)) {
                        teachersInColumn.set(teacherCode, []);
                    }
                    teachersInColumn.get(teacherCode).push({
                        cell: cell,
                        span: teacherSpan
                    });
                }
            }
        }

        // Check for conflicts and highlight them
        teachersInColumn.forEach((occurrences, teacherCode) => {
            if (occurrences.length > 1) {
                // Conflict found - highlight all cells with this teacher
                occurrences.forEach(({ cell, span }) => {
                    cell.style.cssText = `
                        box-sizing: border-box !important;
                        border: 3px solid #fc6358 !important;
                        margin: 1px !important;
                        padding: 8px !important;
                        position: relative !important;
                    `;
                    // Preserve teacher color class
                    const colorClass = getTeacherColorClass(teacherCode);
                    span.className = `teacher-initial ${colorClass}`;
                });
            } else {
                // No conflict - set normal styling
                const { cell, span } = occurrences[0];
                cell.style.cssText = `
                    box-sizing: border-box !important;
                    border: 2.5px solid #ccc !important;
                    margin: 1px !important;
                    padding: 8px !important;
                    position: relative !important;
                `;
                // Preserve teacher color class
                const colorClass = getTeacherColorClass(teacherCode);
                span.className = `teacher-initial ${colorClass}`;
            }
        });
    }
}

// Add this function after the existing code
function handlePrintStyles(action) {
    const tables = document.querySelectorAll('.timetable');
    tables.forEach(table => {
        const cells = table.querySelectorAll('td');
        cells.forEach(cell => {
            if (action === 'hide') {
                // Store original border color if it's a conflict
                if (cell.style.borderColor === 'rgb(252, 99, 88)') {
                    cell.dataset.originalBorder = cell.style.cssText;
                    cell.style.cssText = `
                        box-sizing: border-box !important;
                        border: 2.5px solid #ccc !important;
                        margin: 1px !important;
                        padding: 8px !important;
                        position: relative !important;
                    `;
                }
            } else if (action === 'restore') {
                // Restore original border color if it was stored
                if (cell.dataset.originalBorder) {
                    cell.style.cssText = cell.dataset.originalBorder;
                    delete cell.dataset.originalBorder;
                }
            }
        });
    });
}