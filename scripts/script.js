document.addEventListener('DOMContentLoaded', (event) => {
    console.log('DOM fully loaded and parsed');

    const btn = document.querySelector('[data-btn]');
    const clear = document.querySelector('[data-clear]');
    const cells = document.querySelectorAll('[data-cell]');
    let draggedElement = null;

    const fetchCourses = async () => {
        try {
            const response = await fetch('fetch_courses.php');
            const data = await response.json();
            return data;
        } catch (error) {
            console.error("Error fetching courses:", error);
            return [];
        }
    };

    const clearTimetable = () => {
        cells.forEach(el => el.innerHTML = '');
        localStorage.removeItem('timetableState'); // Clear storage when clearing table
    };

    const populateTimetable = async () => {
        const courses = await fetchCourses();

        if (courses.length === 0) {
            console.warn("No courses available to populate.");
            return;
        }

        cells.forEach(cell => {
            const randomIndex = Math.floor(Math.random() * courses.length);
            cell.innerHTML = courses[randomIndex];
            cell.setAttribute('draggable', true);
        });

        setupDragAndDrop();
        saveTimetableState(); // Save after populating
    };

    const handleDragStart = (e) => {
        draggedElement = e.target;
        e.target.classList.add('dragging');
        e.target.style.opacity = '0.6';
        e.dataTransfer.effectAllowed = 'move';
    };

    const handleDragEnd = (e) => {
        e.target.classList.remove('dragging');
        e.target.style.opacity = '1';
        cells.forEach(cell => {
            cell.style.boxShadow = '';
            cell.style.border = '';
        });
    };

    const handleDragOver = (e) => {
        e.preventDefault();
        const target = e.target;
        if (target.hasAttribute('data-cell')) {
            e.dataTransfer.dropEffect = 'move';
            target.style.boxShadow = '0 0 10px rgba(0,0,0,0.3) inset';
            target.style.border = '2px dashed #666';
        }
    };

    const handleDragLeave = (e) => {
        const target = e.target;
        if (target.hasAttribute('data-cell')) {
            target.style.boxShadow = '';
            target.style.border = '';
        }
    };

    const handleDrop = (e) => {
        e.preventDefault();
        const target = e.target;
        target.style.border = '';

        if (draggedElement && draggedElement !== target) {
            // Backup original states
            const draggedState = {
                content: draggedElement.innerHTML,
                bgColor: draggedElement.style.backgroundColor,
                color: draggedElement.style.color,
                fontSize: draggedElement.style.fontSize
            };

            const targetState = {
                content: target.innerHTML,
                bgColor: target.style.backgroundColor,
                color: target.style.color,
                fontSize: target.style.fontSize
            };

            try {
                // Perform swap
                target.innerHTML = draggedState.content;
                target.style.backgroundColor = draggedState.bgColor;
                target.style.color = draggedState.color;
                target.style.fontSize = draggedState.fontSize;

                draggedElement.innerHTML = targetState.content;
                draggedElement.style.backgroundColor = targetState.bgColor;
                draggedElement.style.color = targetState.color;
                draggedElement.style.fontSize = targetState.fontSize;

                // Ensure draggable state
                target.setAttribute('draggable', true);
                draggedElement.setAttribute('draggable', true);

                // Save state
                saveTimetableState();
            } catch (error) {
                console.error('Error during swap:', error);
                // Revert changes if swap fails
                target.innerHTML = targetState.content;
                draggedElement.innerHTML = draggedState.content;
            }
        }
        draggedElement = null;
    };

    const setupDragAndDrop = () => {
        cells.forEach(cell => {
            cell.removeEventListener('dragstart', handleDragStart);
            cell.removeEventListener('dragend', handleDragEnd);
            cell.removeEventListener('dragover', handleDragOver);
            cell.removeEventListener('dragleave', handleDragLeave);
            cell.removeEventListener('drop', handleDrop);

            cell.addEventListener('dragstart', handleDragStart);
            cell.addEventListener('dragend', handleDragEnd);
            cell.addEventListener('dragover', handleDragOver);
            cell.addEventListener('dragleave', handleDragLeave);
            cell.addEventListener('drop', handleDrop);
        });
    };

    btn.addEventListener('click', populateTimetable);
    clear.addEventListener('click', clearTimetable);

    // Notes
    const addNoteBtn = document.getElementById('add-note-btn');
    const noteInput = document.getElementById('note-input');

    const addNoteHandler = () => {
        console.log('Add Note button clicked');
        const noteText = noteInput.value.trim();
        if (noteText !== '') {
            addNote(noteText);
            noteInput.value = '';
        } else {
            console.log('Note input is empty');
        }
    };

    addNoteBtn.addEventListener('click', addNoteHandler);

    noteInput.addEventListener('keypress', function(event) {
        if (event.key === 'Enter') {
            event.preventDefault();
            addNoteHandler();
        }
    });

    function addNote(text) {
        console.log('Adding note:', text);
        const notesList = document.getElementById('notes-list');
        const noteItem = document.createElement('li');
        noteItem.className = 'note-item';
        noteItem.innerHTML = `
            <span contenteditable="true">${text}</span>
            <button class="delete-note-btn">Delete</button>
        `;
        noteItem.style.backgroundColor = getRandomColor();
        notesList.appendChild(noteItem);

        // Attach event listener for delete button
        noteItem.querySelector('.delete-note-btn').addEventListener('click', function() {
            deleteNote(this);
        });
    }

    function getRandomColor() {
        const colors = [
            '#FFCDD2', '#F8BBD0', '#E1BEE7', '#D1C4E9', '#C5CAE9',
            '#BBDEFB', '#B3E5FC', '#B2EBF2', '#B2DFDB', '#C8E6C9',
            '#DCEDC8', '#F0F4C3', '#FFF9C4', '#FFECB3', '#FFE0B2',
            '#FFCCBC', '#D7CCC8', '#F5F5F5', '#CFD8DC'
        ];
        const randomIndex = Math.floor(Math.random() * colors.length);
        return colors[randomIndex];
    }

    function deleteNote(button) {
        console.log('Deleting note');
        const noteItem = button.parentElement;
        noteItem.remove();
    }

    function Print() {
        window.print();
    }

    // document.getElementById('print-btn').addEventListener('click', Print);

    // Customization settings
    const cellColorInput = document.getElementById('cell-color');
    const fontColorInput = document.getElementById('font-color');
    const fontSizeInput = document.getElementById('font-size');
    const resetSettingsBtn = document.getElementById('reset-settings-btn');

    const applySettings = () => {
        const cellColor = cellColorInput.value;
        const fontColor = fontColorInput.value;
        const fontSize = fontSizeInput.value;

        console.log('Applying settings:', { cellColor, fontColor, fontSize });

        // Apply individual settings
        cells.forEach(cell => {
            if (cellColor) cell.style.backgroundColor = cellColor;
            if (fontColor) {
                cell.style.color = fontColor;
                cell.style.borderColor = 'black'; // Set border color to default black
            }
            if (fontSize) cell.style.fontSize = `${fontSize}px`;
        });
        
        saveTimetableState(); // Save after applying settings
    };

    const resetSettings = () => {
        cellColorInput.value = '';
        fontColorInput.value = '';
        fontSizeInput.value = '';

        cells.forEach(cell => {
            cell.style.backgroundColor = '';
            cell.style.color = '';
            cell.style.fontSize = '';
            cell.style.borderColor = '';
        });
    };

    cellColorInput.addEventListener('input', applySettings);
    fontColorInput.addEventListener('input', applySettings);
    fontSizeInput.addEventListener('input', applySettings);
    resetSettingsBtn.addEventListener('click', resetSettings);

    const getStorageKey = () => {
        const className = document.querySelector('h2').textContent.trim();
        return `timetableState_${className}`;
    };

    // Update save function
    const saveTimetableState = () => {
        const timetableData = {};
        cells.forEach((cell, index) => {
            timetableData[index] = {
                content: cell.innerHTML,
                isDisabled: cell.classList.contains('disabled'),
                backgroundColor: cell.style.backgroundColor,
                color: cell.style.color,
                fontSize: cell.style.fontSize
            };
        });
        localStorage.setItem(getStorageKey(), JSON.stringify(timetableData));
    };

    // Update load function
    const loadTimetableState = () => {
        const savedState = localStorage.getItem(getStorageKey());
        if (savedState) {
            const timetableData = JSON.parse(savedState);
            cells.forEach((cell, index) => {
                if (timetableData[index]) {
                    cell.innerHTML = timetableData[index].content;
                    cell.style.backgroundColor = timetableData[index].backgroundColor;
                    cell.style.color = timetableData[index].color;
                    cell.style.fontSize = timetableData[index].fontSize;
                    if (cell.innerHTML) {
                        cell.setAttribute('draggable', true);
                    }
                }
            });
            setupDragAndDrop();
        }
    };

    // Load saved timetable state
    loadTimetableState();

    // Initialize drag and drop on page load
    setupDragAndDrop();
});