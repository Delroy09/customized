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

        addDragAndDropListeners();
    };

    const addDragAndDropListeners = () => {
        cells.forEach(cell => {
            cell.addEventListener('dragstart', (e) => {
                draggedElement = e.target;
                e.dataTransfer.effectAllowed = 'move';
            });

            cell.addEventListener('dragover', (e) => {
                e.preventDefault();
                e.dataTransfer.dropEffect = 'move';
            });

            cell.addEventListener('drop', (e) => {
                e.preventDefault();
                if (draggedElement && draggedElement !== e.target) {
                    const temp = e.target.innerHTML;
                    e.target.innerHTML = draggedElement.innerHTML;
                    draggedElement.innerHTML = temp;
                }
            });
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
});