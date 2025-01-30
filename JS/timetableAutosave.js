class TimetableAutosave {
    constructor(semester) {
        this.semester = semester;
        this.storageKey = `timetable_layout_${semester}`;
        this.cells = document.querySelectorAll('.timetable td:not(:first-child):not(.recess)');

        // Store reference to autosave instance on ALL tables
        document.querySelectorAll('.timetable').forEach(table => {
            table.autosaveInstance = this;
        });

        this.initializeAutosave();
    }

    initializeAutosave() {
        // Load saved layout on page load
        this.loadLayout();

        // Save layout when cells are modified
        this.cells.forEach(cell => {
            cell.addEventListener('dragend', () => this.saveLayout());
        });

        this.cells.forEach(cell => {
            cell.addEventListener('contextmenu', () => {
                // Add small delay to ensure content is updated
                setTimeout(() => this.saveLayout(), 100);
            });
        });

        // Add reset button functionality
        const resetButton = document.getElementById('reset-layout');
        if (resetButton) {
            resetButton.addEventListener('click', () => this.resetLayout());
        }
    }

    saveLayout() {
        const layout = {};
        const allTables = document.querySelectorAll('.timetable');
        
        allTables.forEach((table, tableIndex) => {
            const cells = table.querySelectorAll('td:not(:first-child):not(.recess)');
            const day = table.previousElementSibling.textContent.trim();
            
            cells.forEach((cell, cellIndex) => {
                const key = `${tableIndex}-${cellIndex}`;
                layout[key] = {
                    content: cell.innerHTML,
                    day: day,
                    period: cell.cellIndex,
                    isEmpty: cell.innerHTML === '-'
                };
            });
        });
        
        localStorage.setItem(this.storageKey, JSON.stringify(layout));
    }

    loadLayout() {
        const savedLayout = localStorage.getItem(this.storageKey);
        if (savedLayout) {
            const layout = JSON.parse(savedLayout);
            const allTables = document.querySelectorAll('.timetable');
            
            allTables.forEach((table, tableIndex) => {
                const cells = table.querySelectorAll('td:not(:first-child):not(.recess)');
                const day = table.previousElementSibling.textContent.trim();
                
                cells.forEach((cell, cellIndex) => {
                    const key = `${tableIndex}-${cellIndex}`;
                    if (layout[key] && layout[key].day === day && layout[key].period === cell.cellIndex) {
                        cell.innerHTML = layout[key].isEmpty ? '-' : layout[key].content;
                    }
                });
            });
        }
    }

    resetLayout() {
        localStorage.removeItem(this.storageKey);
        location.reload();
    }
}