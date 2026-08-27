SELECT e.first_name, e.last_name, e.department, d.manager, d.office_floor
FROM employees e
INNER JOIN departments d ON e.department = d.department_name
