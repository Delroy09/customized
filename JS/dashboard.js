// Restrict inputs to text only (no numbers) for teacher fields
document.getElementById('teacherInitial').addEventListener('input', (event) => {
    const value = event.target.value;
    // Remove any digit characters
    event.target.value = value.replace(/[0-9]/g, '');
});

document.getElementById('teacherName').addEventListener('input', (event) => {
    const value = event.target.value;
    // Remove any digit characters
    event.target.value = value.replace(/[0-9]/g, '');
});

// Teacher section
document.querySelector('.sidebar ul li:nth-child(2) a').addEventListener('click', () => {
    // Show the teacher section and hide others
    document.getElementById('teacher-section').style.display = 'block';
    document.getElementById('teacher-data').style.display = 'block';
    document.getElementById('teacher-search').style.display = 'block';

    document.getElementById('course-section').style.display = 'none';
    document.getElementById('course-data').style.display = 'none';
    document.getElementById('course-search').style.display = 'none';

    document.getElementById('allocation-section').style.display = 'none'; // Hide allocation section
    document.getElementById('allocation-data').style.display = 'none';
    document.getElementById('odd-sem-section').style.display = 'none';

    document.getElementById('searchCourse').value = '';
    
});

// Course section
document.querySelector('.sidebar ul li:nth-child(1) a').addEventListener('click', () => {
    // Show the course section and hide others
    document.getElementById('course-section').style.display = 'block';
    document.getElementById('course-data').style.display = 'block';
    document.getElementById('course-search').style.display = 'block';

    document.getElementById('teacher-section').style.display = 'none';
    document.getElementById('teacher-data').style.display = 'none';
    document.getElementById('teacher-search').style.display = 'none';
    document.getElementById('allocation-search').style.display = 'none';

    document.getElementById('allocation-section').style.display = 'none';
    document.getElementById('allocation-data').style.display = 'none';
    document.getElementById('odd-sem-section').style.display = 'none';

    document.getElementById('searchTeacher').value = '';
});

// Course allocation
document.querySelector('.sidebar ul li:nth-child(3) a').addEventListener('click', () => {
    // Show the allocation section and hide others
    document.getElementById('allocation-section').style.display = 'block';
    document.getElementById('allocation-data').style.display = 'block';
    document.getElementById('allocation-search').style.display = 'block';

    document.getElementById('course-section').style.display = 'none';
    document.getElementById('course-data').style.display = 'none';
    document.getElementById('course-search').style.display = 'none';
    document.getElementById('teacher-search').style.display = 'none';

    document.getElementById('teacher-section').style.display = 'none';
    document.getElementById('teacher-data').style.display = 'none';
    document.getElementById('odd-sem-section').style.display = 'none';
});


// Odd semester timetable section
document.getElementById('odd-ic').addEventListener('click', () => {
    // Hide all other sections
    document.getElementById('teacher-section').style.display = 'none';
    document.getElementById('teacher-data').style.display = 'none';
    document.getElementById('teacher-search').style.display = 'none';

    document.getElementById('course-section').style.display = 'none';
    document.getElementById('course-data').style.display = 'none';
    document.getElementById('course-search').style.display = 'none';

    document.getElementById('allocation-section').style.display = 'none';
    document.getElementById('allocation-data').style.display = 'none';
    document.getElementById('allocation-search').style.display = 'none';

    // Show odd semester section
    document.getElementById('odd-sem-section').style.display = 'none';
    
    // Fetch semesters and programmes
    fetchSemestersAndProgrammes();
});

function fetchSemestersAndProgrammes() {
    fetch('fetch_sem_prog.php')
        .then(response => response.json())
        .then(data => {
            const semesterSelect = document.getElementById('oddSemester');
            const programmeSelect = document.getElementById('oddProgramme');
            
            // Clear existing options
            semesterSelect.innerHTML = '<option disabled selected></option>';
            programmeSelect.innerHTML = '<option disabled selected></option>';
            
            // Add odd semester options
            data.semesters.forEach(semester => {
                if (semester.semesterID % 2 !== 0) { // Only odd semesters
                    const option = document.createElement('option');
                    option.value = semester.semesterID;
                    option.textContent = semester.semesterName;
                    semesterSelect.appendChild(option);
                }
            });
            
            // Add programme options
            data.programmes.forEach(programme => {
                const option = document.createElement('option');
                option.value = programme.programmeID;
                option.textContent = programme.programmeName;
                programmeSelect.appendChild(option);
            });
        })
        .catch(error => console.error('Error:', error));
}

// Add event listener for generate timetable button
document.getElementById('generate-timetable').addEventListener('click', function() {
    const semester = document.getElementById('oddSemester').value;
    const programme = document.getElementById('oddProgramme').value;

    if (!semester || !programme) {
        alert('Please select both semester and programme');
        return;
    }

    // Open timetable in new window/tab
    window.open(`generate_timetable.php?semester=${semester}&programme=${programme}`, '_blank');
});

function activateLink(element) {
    const links = document.querySelectorAll('.nav-link');
    links.forEach(link => {
      link.classList.remove('active');
      const img = link.querySelector('img');
      if (img) {
        img.src = img.src.replace('-2.png', '-1.png');
      }
    });

    element.classList.add('active');

    const img = element.querySelector('img');
    if (img) {
      img.src = img.src.replace('-1.png', '-2.png');
    }
  }

//CRUD Operation (Teacher)

// Add teacher
document.getElementById('add').addEventListener('click', () => {
    const teacherInitial = document.getElementById('teacherInitial');
    const teacherName = document.getElementById('teacherName');

    if (!teacherInitial.value.trim()) {
        teacherInitial.setCustomValidity('Please fill in this field.');
        teacherInitial.reportValidity();
    } else if (!teacherName.value.trim()) {
        teacherName.setCustomValidity('Please fill in this field.');
        teacherName.reportValidity();
    } else {
        teacherInitial.setCustomValidity('');
        teacherName.setCustomValidity('');

        const formData = new FormData();
        formData.append('action', 'add');
        formData.append('teacherInitial', teacherInitial.value.trim());
        formData.append('teacherName', teacherName.value.trim());

        fetch('teacher.php', {
            method: 'POST',
            body: formData,
        })
            .then((response) => response.json())
            .then((data) => {
                if (data.success) {
                    alert('Teacher added successfully!');
                    fetchTeachers();
                    document.getElementById('teacher-form').reset();
                } else {
                    alert('Failed to add teacher: ' + data.message);
                }
            })
            .catch((error) => console.error('Error:', error));
    }
});

// Fectch eacher
function fetchTeachers() {
    fetch('teacher.php?action=read')
        .then((response) => response.json())
        .then((data) => {
            const tbody = document.querySelector('#teacher-table tbody');
            tbody.innerHTML = '';

            data.forEach((teacher) => {
                const row = document.createElement('tr');
                row.innerHTML = `
                    <td>${teacher.teacherInitial}</td>
                    <td>${teacher.teacherName}</td>
                    <td><button class="update-btn" onclick="updateTeacher('${teacher.teacherInitial}')"></button></td>
                    <td><button class="delete-btn" onclick="deleteTeacher('${teacher.teacherInitial}')"></button></td>
                `;
                tbody.appendChild(row);
            });
        })
        .catch((error) => console.error('Error:', error));
}

let editingTeacherInitial = null;

// Update teacher
function updateTeacher(currentInitial) {
    fetch(`teacher.php?action=read`)
        .then((response) => response.json())
        .then((teachers) => {
            const teacher = teachers.find(t => t.teacherInitial === currentInitial);
            if (teacher) {
                // Populate the form fields with the teacher's data
                document.getElementById('teacherInitial').value = teacher.teacherInitial;
                document.getElementById('teacherName').value = teacher.teacherName;

                // Scroll to the top smoothly
                window.scrollTo({
                    top: 0,
                    behavior: 'smooth'  // Smooth scrolling to top
                });

                // Set the current initial for updating
                editingTeacherInitial = currentInitial;

                // Show the Update button and hide the Add button
                document.getElementById('add').style.display = 'none';
                let updateButton = document.getElementById('update');
                if (!updateButton) {
                    // Create the Update button if it doesn't exist
                    updateButton = document.createElement('button');
                    updateButton.id = 'update';
                    updateButton.textContent = 'Update';
                    updateButton.type = 'button';
                    updateButton.onclick = performUpdate;

                    // Prepend the Update button to the button group
                    const buttonGroup = document.querySelector('.button-group');
                    buttonGroup.insertBefore(updateButton, buttonGroup.firstChild);
                }
                updateButton.style.display = 'inline-block';
            } else {
                alert('Teacher not found. Please try again.');
            }
        })
        .catch((error) => {
            console.error('Error fetching teacher details:', error);
            alert('Failed to fetch teacher details. Please check your connection or try again.');
        });
}

// Perform update for the teacher
function performUpdate() {
    const teacherInitialInput = document.getElementById('teacherInitial');
    const teacherNameInput = document.getElementById('teacherName');

    const newInitial = teacherInitialInput.value.trim();
    const newName = teacherNameInput.value.trim();

    if (newInitial && newName) {
        const formData = new FormData();
        formData.append('action', 'update');
        formData.append('currentInitial', editingTeacherInitial);
        formData.append('newInitial', newInitial);
        formData.append('teacherName', newName);

        fetch('teacher.php', {
            method: 'POST',
            body: formData,
        })
            .then((response) => response.json())
            .then((data) => {
                if (data.success) {
                    alert('Teacher updated successfully!');
                    fetchTeachers();

                    // Reset the form and buttons
                    document.getElementById('teacher-form').reset();
                    document.getElementById('add').style.display = 'inline-block';
                    document.getElementById('update').style.display = 'none';
                    editingTeacherInitial = null;
                } else {
                    alert('Failed to update teacher: ' + data.message);
                }
            })
            .catch((error) => {
                console.error('Error updating teacher:', error);
                alert('An error occurred while updating the teacher. Please try again.');
            });
    } else {
        if (!newInitial) {
            teacherInitialInput.setCustomValidity('Please fill in this field.');
            teacherInitialInput.reportValidity();
        }
        if (!newName) {
            teacherNameInput.setCustomValidity('Please fill in this field.');
            teacherNameInput.reportValidity();
        }
    }
}



// Reset button functionality for teacher (make add button visible upon reset)
document.querySelector('.button-group button[type="reset"]').addEventListener('click', () => {
    // Reset buttons: Show "Add", hide "Update"
    document.getElementById('add').style.display = 'inline-block';
    const updateButton = document.getElementById('update');
    if (updateButton) {
        updateButton.style.display = 'none';
    }

    // Clear editing state
    editingTeacherInitial = null;
});


// Delete teacher
function deleteTeacher(teacherInitial) {
    if (confirm('Are you sure you want to delete this teacher?')) {
        const formData = new FormData();
        formData.append('action', 'delete');
        formData.append('teacherInitial', teacherInitial);

        fetch('teacher.php', {
            method: 'POST',
            body: formData,
        })
            .then((response) => response.json())
            .then((data) => {
                if (data.success) {
                    alert('Teacher deleted successfully!');
                    fetchTeachers();
                } else {
                    alert('Failed to delete teacher: ' + data.message);
                }
            })
            .catch((error) => console.error('Error:', error));
    }
}

// Fetch teachers on page load
document.querySelector('.sidebar ul li:nth-child(2) a').addEventListener('click', fetchTeachers);



//CRUD Operation (Course)

const courseTableBody = document.querySelector("#course-table tbody");
const courseForm = document.getElementById("course-form");

// Function to fetch and display courses
function fetchCourses() {
    fetch("course.php")
        .then(response => response.json())
        .then(data => {
            courseTableBody.innerHTML = ""; // Clear existing rows
            data.forEach(course => {
                courseTableBody.innerHTML += `
                    <tr>
                        <td>${course.courseID}</td>
                        <td>${course.courseName}</td>
                        <td>${course.courseInitial}</td>
                        <td>${course.courseType}</td>
                        <td>${course.isPracIncluded}</td>
                        <td>${course.theoryHrs}</td>
                        <td>${course.pracHrs}</td>
                        <td>${course.theoryCredits}</td>
                        <td>${course.pracCredits}</td>
                        <td>${course.semesterID}</td>
                        <td>${course.programmeID}</td>
                        <td><button class="update-btn" onclick="editCourse('${course.courseID}', '${course.courseName}', '${course.courseInitial}', '${course.courseType}', '${course.isPracIncluded}', ${course.theoryHrs}, ${course.pracHrs}, ${course.theoryCredits}, ${course.pracCredits}, ${course.semesterID}, '${course.programmeID}')"></button></td>
                        <td><button class="delete-btn" onclick="deleteCourse('${course.courseID}')"></button></td>
                    </tr>
                `;
            });
        })
        .catch(error => console.error('Error fetching courses:', error));
}


// Function to add a new course
document.getElementById("course-form").addEventListener("submit", function (event) {
    event.preventDefault(); // Prevent the form from being submitted traditionally

    // Get the form and prepare the form data
    const formData = new FormData(this); // 'this' refers to the form
    formData.append("action", "add");

    // Log the form data to check the values
    for (var pair of formData.entries()) {
        console.log(pair[0] + ', ' + pair[1]);
    }

    // Send the form data using Fetch API
    fetch("course.php", {
        method: "POST",
        body: formData
    })
    .then(response => response.json())  // Expecting JSON response
    .then(result => {
        if (result.success) {
            alert(result.message);  // Success message
            fetchCourses();  // Refresh the course list
            courseForm.reset();  // Reset the form after successful submission
        } else {
            alert("Error adding course.");
        }
    })
    .catch(err => {
        alert("An error occurred while adding the course.");
        console.error(err);  // Log the error for debugging
    });
});



// Function to delete a course
function deleteCourse(courseID) {
    if (confirm("Are you sure you want to delete this course?")) {
        const formData = new FormData();
        formData.append("action", "delete");
        formData.append("courseID", courseID);

        fetch("course.php", {
            method: "POST",
            body: formData
        })
            .then(response => response.json())
            .then(result => {
                if (result.success) {
                    alert(result.message);
                    fetchCourses(); // Refresh the course list
                } else {
                    alert("Error deleting course.");
                }
            });
    }
}


// Function to update a course
function editCourse(courseID, courseName, courseInitial, courseType, isPracIncluded, theoryHrs, pracHrs, theoryCredits, pracCredits, semesterID, programmeID) {

    // Scroll to top when the update button is clicked
    window.scrollTo({
        top: 0,
        behavior: 'smooth'  // Smooth scrolling
    });

    // Fill the form with the existing course data
    document.getElementById('courseID').value = courseID;
    document.getElementById('courseName').value = courseName;
    document.getElementById('courseInitial').value = courseInitial;
    document.getElementById('courseType').value = courseType;
    document.getElementById('isPracIncluded').value = isPracIncluded;
    document.getElementById('theoryHrs').value = theoryHrs;
    document.getElementById('pracHrs').value = pracHrs;
    document.getElementById('theoryCredits').value = theoryCredits;
    document.getElementById('pracCredits').value = pracCredits;
    document.getElementById('semesterID').value = semesterID;
    document.getElementById('programmeID').value = programmeID;

    // Make courseID readonly
    document.getElementById('courseID').readOnly = true;  // Ensure it's readonly

    // Hide Add button and show Update button
    document.getElementById("add-course").style.display = "none";
    document.getElementById("update-course").style.display = "inline-block";

    // Store the course ID in a global variable to use it when updating
    window.selectedCourseID = courseID; // Ensure the course ID is stored correctly
}


// After updating the course or resetting the form, clear the selectedCourseID
document.getElementById("update-course").addEventListener("click", function () {
    const courseID = window.selectedCourseID; // Get the selected course ID
    const courseName = document.getElementById('courseName').value;
    const courseInitial = document.getElementById('courseInitial').value;
    const courseType = document.getElementById('courseType').value;
    const isPracIncluded = document.getElementById('isPracIncluded').value;
    const theoryHrs = document.getElementById('theoryHrs').value;
    const pracHrs = document.getElementById('pracHrs').value;
    const theoryCredits = document.getElementById('theoryCredits').value;
    const pracCredits = document.getElementById('pracCredits').value;
    const semesterID = document.getElementById('semesterID').value;
    const programmeID = document.getElementById('programmeID').value;

    // Ensure courseID is available and required fields are filled
    if (courseID && courseName && courseInitial) {
        const formData = new FormData();
        formData.append("action", "update");
        formData.append("courseID", courseID);
        formData.append("courseName", courseName);
        formData.append("courseInitial", courseInitial);
        formData.append("courseType", courseType);
        formData.append("isPracIncluded", isPracIncluded);
        formData.append("theoryHrs", theoryHrs);
        formData.append("pracHrs", pracHrs);
        formData.append("theoryCredits", theoryCredits);
        formData.append("pracCredits", pracCredits);
        formData.append("semesterID", semesterID);
        formData.append("programmeID", programmeID);

        // Send the form data using Fetch API
        fetch("course.php", {
            method: "POST",
            body: formData
        })
        .then(response => response.json())
        .then(result => {
            if (result.success) {
                alert(result.message);  // Success message
                fetchCourses();  // Refresh the course list
                courseForm.reset();  // Reset the form after successful update
                document.getElementById("add-course").style.display = "inline-block";
                document.getElementById("update-course").style.display = "none"; // Hide update button after update
            } else {
                alert("Error updating course.");
            }
        })
        .catch(err => {
            alert("An error occurred while updating the course.");
            console.error(err);  // Log the error for debugging
        });
    } else {
        alert("Please fill in all fields.");
    }
});

document.getElementById("course-form").addEventListener("reset", function () {
    // Clear the selected course ID when form is reset
    window.selectedCourseID = null;
});



// Initial fetch of course data when the page loads
document.addEventListener("DOMContentLoaded", function() {
    fetchCourses(); // Call the function to fetch courses when the page loads
});


// Reset button functionality for course (make add button visible upon reset)
document.getElementById("course-form").addEventListener("reset", function () {
    // Clear the global selected course ID variable
    window.selectedCourseID = null;

    // Ensure "Add" button is visible and "Update" button is hidden
    document.getElementById("add-course").style.display = "inline-block";
    document.getElementById("update-course").style.display = "none";

    // Make the course ID field editable again
    document.getElementById("courseID").readOnly = false;
});








//populate dropdowns
document.addEventListener("DOMContentLoaded", function () {
    // Fetch initial data for dropdowns
    fetch("fetch_dropdown.php")
        .then((response) => response.json())
        .then((data) => {
            populateDropdown("teacherInitials", data.teacherInitials);
            populateDropdown("classNo", data.classNo);
            populateDropdown("semesterIDs", data.semesterIDs);
            populateDropdown("programmeIDs", data.programmeIDs);

            // Initially disable courseID dropdown
            toggleDropdown("courseIDs", false);
        })
        .catch((error) => console.error("Error fetching dropdown data:", error));

    // Add event listeners for programmeID and semesterID
    document.getElementById("programmeIDs").addEventListener("change", handleDropdownChange);
    document.getElementById("semesterIDs").addEventListener("change", handleDropdownChange);
});

// Handle dropdown state changes
function handleDropdownChange() {
    const programmeID = document.getElementById("programmeIDs").value;
    const semesterID = document.getElementById("semesterIDs").value;

    if (programmeID && semesterID) {
        fetchFilteredCourses(programmeID, semesterID);
    } else {
        // Clear and disable the courseID dropdown if dependencies are not selected
        populateDropdown("courseIDs", []);
        toggleDropdown("courseIDs", false);
    }
}

// Fetch filtered course IDs based on selected programmeID and semesterID
function fetchFilteredCourses(programmeID, semesterID) {
    return fetch(`fetch_dropdown.php?programmeID=${programmeID}&semesterID=${semesterID}`)
        .then((response) => response.json())
        .then((data) => {
            populateDropdown("courseIDs", data.courseIDs);
            toggleDropdown("courseIDs", true); // Enable courseID dropdown after populating
        })
        .catch((error) => console.error("Error fetching filtered courses:", error));
}

// Helper function to populate dropdowns
function populateDropdown(dropdownId, values) {
    const dropdown = document.getElementById(dropdownId);
    dropdown.innerHTML = '<option disabled selected></option>'; // Reset dropdown
    values.forEach((value) => {
        const option = document.createElement("option");
        if (dropdownId === "teacherInitials") {
            // Extract the actual value (initial) and display text (initial - name)
            const [initial, ...nameParts] = value.split(" - ");
            const displayText = value; // Full text like "JD - John Doe"
            option.value = initial; // Only use the initial for value
            option.textContent = displayText;
        } else {
            option.value = value;
            option.textContent = value;
        }
        dropdown.appendChild(option);
    });
}


// Helper function to enable or disable dropdowns
function toggleDropdown(dropdownId, isEnabled) {
    const dropdown = document.getElementById(dropdownId);
    dropdown.disabled = !isEnabled;
}






//CRUD Operation (Course)
const allocationTableBody = document.querySelector("#allocation-table tbody");
const allocationForm = document.getElementById("allocation-form");

// Function to fetch and display allocations
function fetchAllocations() {
    fetch("allocation.php")
        .then(response => response.json())
        .then(data => {
            allocationTableBody.innerHTML = ""; // Clear existing rows
            data.forEach(allocation => {
                allocationTableBody.innerHTML += `
                    <tr>
                        <td>${allocation.teacherInitial}</td>
                        <td>${allocation.courseID}</td>
                        <td>${allocation.classNo}</td>
                        <td>${allocation.lab}</td>
                        <td>${allocation.semesterID}</td>
                        <td>${allocation.programmeID}</td>
                        <td><button class="update-btn" onclick="editAllocation(${allocation.id}, '${allocation.teacherInitial}', '${allocation.courseID}', '${allocation.classNo}', '${allocation.lab}', '${allocation.semesterID}', '${allocation.programmeID}')"></button></td>
                        <td><button class="delete-btn" onclick="deleteAllocation(${allocation.id})"></button></td>
                    </tr>
                `;
            });
        })
        .catch(error => console.error('Error fetching allocations:', error));
}

// Function to add a new allocation
document.getElementById("allocation-form").addEventListener("submit", function (event) {
    event.preventDefault(); // Prevent default submission

    const formData = new FormData(this);
    formData.append("action", "add");

    fetch("allocation.php", {
        method: "POST",
        body: formData
    })
        .then(response => response.json())
        .then(result => {
            if (result.success) {
                alert(result.message);
                fetchAllocations();
                allocationForm.reset();
            } else {
                alert("Error adding allocation.");
            }
        })
        .catch(err => {
            alert("An error occurred while adding allocation.");
            console.error(err);
        });
});

// Function to delete an allocation
function deleteAllocation(allocationID) {
    if (confirm("Are you sure you want to delete this allocation?")) {
        const formData = new FormData();
        formData.append("action", "delete");
        formData.append("allocationID", allocationID);

        fetch("allocation.php", {
            method: "POST",
            body: formData
        })
            .then(response => response.json())
            .then(result => {
                if (result.success) {
                    alert(result.message);
                    fetchAllocations();
                } else {
                    alert("Error deleting allocation.");
                }
            });
    }
}

// Function to edit an allocation
function editAllocation(id, teacherInitial, courseID, classNo, lab, semesterID, programmeID) {
    window.scrollTo({ top: 0, behavior: 'smooth' });

    // Get the teacher dropdown and set its value based on teacherInitial
    const teacherDropdown = document.getElementById('teacherInitials');
    const teacherOption = [...teacherDropdown.options].find(option => option.value === teacherInitial);
    if (teacherOption) {
        teacherDropdown.value = teacherOption.value;
    } else {
        console.error(`Teacher initial ${teacherInitial} not found in dropdown.`);
    }

    // Set programmeID and semesterID first
    document.getElementById('programmeIDs').value = programmeID;
    document.getElementById('semesterIDs').value = semesterID;

    // Fetch and populate courses, then set courseID and other fields
    if (programmeID && semesterID) {
        fetchFilteredCourses(programmeID, semesterID)
            .then(() => {
                // Wait until courses are populated
                const courseDropdown = document.getElementById('courseIDs');
                const courseOption = [...courseDropdown.options].find(option => option.value === courseID);
                if (courseOption) {
                    courseDropdown.value = courseID;
                } else {
                    console.error(`Course ID ${courseID} not found in dropdown.`);
                }

                // Populate classNo and lab fields after courseID is set
                document.getElementById('classNo').value = classNo;
                const labField = document.getElementById('lab');
                labField.value = lab || "";
                labField.disabled = !lab || lab.trim() === "";
            })
            .catch(error => console.error("Error fetching courses:", error));
    } else {
        console.error("Programme ID and Semester ID must be selected.");
    }

    // Save the allocation ID for updating
    window.selectedAllocationID = id;

    // Show/hide the appropriate buttons
    document.getElementById("add-allocation").style.display = "none";
    document.getElementById("update-allocation").style.display = "inline-block";
}


// Handle dropdown state changes (reused logic)
function handleDropdownChange() {
    const programmeID = document.getElementById("programmeIDs").value;
    const semesterID = document.getElementById("semesterIDs").value;

    if (programmeID && semesterID) {
        fetchFilteredCourses(programmeID, semesterID);
    } else {
        // Clear and disable the courseID dropdown if dependencies are not selected
        populateDropdown("courseIDs", []);
        toggleDropdown("courseIDs", false);
    }
}

// Handle update allocation submission
document.getElementById("update-allocation").addEventListener("click", function () {
    const id = window.selectedAllocationID;
    const teacherInitial = document.getElementById('teacherInitials').value;
    const courseID = document.getElementById('courseIDs').value;
    const classNo = document.getElementById('classNo').value;
    const lab = document.getElementById('lab').value;
    const semesterID = document.getElementById('semesterIDs').value;
    const programmeID = document.getElementById('programmeIDs').value;

    if (!programmeID || !semesterID || !courseID) {
        alert("Please select Programme ID, Semester ID, and Course ID before updating.");
        return;
    }

    const formData = new FormData();
    formData.append("action", "update");
    formData.append("allocationID", id);
    formData.append("teacherInitial", teacherInitial);
    formData.append("courseID", courseID);
    formData.append("classNo", classNo);
    formData.append("lab", lab);
    formData.append("semesterID", semesterID);
    formData.append("programmeID", programmeID);

    fetch("allocation.php", {
        method: "POST",
        body: formData
    })
        .then(response => response.json())
        .then(result => {
            if (result.success) {
                alert(result.message);
                fetchAllocations();
                allocationForm.reset();
                document.getElementById("add-allocation").style.display = "inline-block";
                document.getElementById("update-allocation").style.display = "none";
            } else {
                alert("Error updating allocation.");
            }
        });
});

// Reuse the helper functions for dropdown toggle and population
function toggleDropdown(dropdownId, isEnabled) {
    const dropdown = document.getElementById(dropdownId);
    dropdown.disabled = !isEnabled;
}




// Clear selectedAllocationID on form reset
document.getElementById("allocation-form").addEventListener("reset", function () {
    window.selectedAllocationID = null;
});

// Initial fetch of allocations on page load
document.addEventListener("DOMContentLoaded", function () {
    fetchAllocations();
});

 // Ensure the lab field is enabled when the reset button is clicked
const clearButton = document.getElementById('clearButton');
    const labField = document.getElementById('lab');

   
    clearButton.addEventListener('click', () => {
        labField.disabled = false; // Enable the lab field
    });

// Reset button functionality for course allocation (make add button visible upon reset)
document.getElementById("allocation-form").addEventListener("reset", function () {
    // Clear selected allocation ID
    window.selectedAllocationID = null;

    // Reset form elements to their default state
    document.getElementById("teacherInitials").value = '';
    document.getElementById("courseIDs").value = '';
    document.getElementById("classNo").value = '';
    document.getElementById("lab").value = '';
    document.getElementById("semesterIDs").value = '';
    document.getElementById("programmeIDs").value = '';

    // Switch buttons back to "Add" mode
    document.getElementById("add-allocation").style.display = "inline-block";
    document.getElementById("update-allocation").style.display = "none";
    
});


















function searchTable(type) {
    const searchInput = document.getElementById(`search${type.charAt(0).toUpperCase() + type.slice(1)}`);
    const table = document.getElementById(`${type}-table`);
    const rows = table.getElementsByTagName('tbody')[0].getElementsByTagName('tr');
    const searchText = searchInput.value.toLowerCase();
    let matchFound = false;

    // Remove existing no-results row if present
    const existingNoResults = table.getElementsByClassName('no-results')[0];
    if (existingNoResults) {
        existingNoResults.remove();
    }

    for (let row of rows) {
        const cells = row.getElementsByTagName('td');
        let rowMatch = false;

        for (let cell of cells) {
            // Remove existing highlights
            cell.innerHTML = cell.innerHTML.replace(/<span class="highlight">|<\/span>/g, '');
            
            const text = cell.textContent;
            if (searchText && text.toLowerCase().includes(searchText)) {
                // Create regex with global and case-insensitive flags
                const regex = new RegExp(`(${searchText})`, 'gi');
                // Replace matching text with highlighted version
                cell.innerHTML = text.replace(regex, '<span class="highlight">$1</span>');
                rowMatch = true;
                matchFound = true;
            }
        }

        if (rowMatch || !searchText) {
            row.style.display = '';
        } else {
            row.style.display = 'none';
        }
    }

    // Show no results message if no matches found
    if (!matchFound && searchText) {
        const tbody = table.getElementsByTagName('tbody')[0];
        const noResultsRow = document.createElement('tr');
        noResultsRow.className = 'no-results';
        noResultsRow.innerHTML = `<td colspan="${type === 'teacher' ? 5 : 13}">No records found</td>`;
        tbody.appendChild(noResultsRow);
    }
}


// Handle odd semester timetable generation
document.getElementById('odd-sem-form').addEventListener('submit', function(e) {
    e.preventDefault();
    const semester = document.getElementById('oddSemester').value;
    const programme = document.getElementById('oddProgramme').value;
    
    // Redirect to timetable display page with parameters
    window.location.href = `display_timetable.php?semester=${semester}&programme=${programme}`;
});

// Fetch semester and programme options when the page loads
fetch('fetch_sem_prog.php')
    .then(response => response.json())
    .then(data => {
        const semesterSelect = document.getElementById('oddSemester');
        const programmeSelect = document.getElementById('oddProgramme');

        // Filter only odd semesters (1, 3, 5)
        data.semesters.filter(sem => sem.semesterID % 2 !== 0).forEach(semester => {
            const option = document.createElement('option');
            option.value = semester.semesterID;
            option.textContent = semester.semesterName;
            semesterSelect.appendChild(option);
        });

        data.programmes.forEach(programme => {
            const option = document.createElement('option');
            option.value = programme.programmeID;
            option.textContent = programme.programmeName;
            programmeSelect.appendChild(option);
        });
    })
    .catch(error => console.error('Error:', error));

    // Add this at the end of your existing dashboard.js file

function sortTable(columnIndex, table) {
    const tbody = table.querySelector('tbody');
    const rows = Array.from(tbody.querySelectorAll('tr'));
    const isAscending = table.getAttribute('data-sort') === 'asc';

    rows.sort((a, b) => {
        const aValue = a.cells[columnIndex].textContent.trim();
        const bValue = b.cells[columnIndex].textContent.trim();
        
        if (!isNaN(aValue) && !isNaN(bValue)) {
            return isAscending ? aValue - bValue : bValue - aValue;
        }
        return isAscending 
            ? bValue.localeCompare(aValue) 
            : aValue.localeCompare(bValue);
    });

    // Toggle sort direction
    table.setAttribute('data-sort', isAscending ? 'desc' : 'asc');
    
    // Remove existing rows and append sorted ones
    rows.forEach(row => tbody.appendChild(row));
}

// Add event listeners to all table headers when page loads
document.addEventListener('DOMContentLoaded', function() {
    const tables = document.querySelectorAll('table');
    
    tables.forEach(table => {
        const headers = table.querySelectorAll('th');
        headers.forEach((header, index) => {
            header.style.cursor = 'pointer';
            header.addEventListener('click', () => sortTable(index, table));
        });
    });
});

// Display the "Course" section by default when the page loads
document.addEventListener("DOMContentLoaded", () => {
    // Hide all sections
    document.querySelectorAll(".main-content > div").forEach((section) => {
        section.style.display = "none";
    });

    // Show the course section
    document.getElementById("course-section").style.display = "block";
    document.getElementById("course-search").style.display = "block";
    document.getElementById("course-data").style.display = "block";

    // Set the active state for the "Course" sidebar link
    const courseLink = document.getElementById("course-ic");
    courseLink.classList.add("active");
});

document.addEventListener("DOMContentLoaded", () => {
    const loaderOverlay = document.getElementById("loader-overlay");
    const oddSemLink = document.getElementById("odd-ic");
    const evenSemLink = document.getElementById("even-ic");

    function showLoader() {
        loaderOverlay.style.display = "flex"; // Show the full-screen loader
    }

    // Attach click event to the links
    oddSemLink.addEventListener("click", showLoader);
    evenSemLink.addEventListener("click", showLoader);
});



