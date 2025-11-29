/**
 * Global script for UI utilities
 */
document.addEventListener('DOMContentLoaded', function() {
	// 1) Auto-insert password toggle button for any input[type=password]
	document.querySelectorAll('input[type="password"]').forEach(function(input) {
		// Skip toggles for read-only or disabled inputs
		if (input.readOnly || input.disabled) return;

		// Ensure input is inside a position-relative container
		var container = input.closest('.position-relative');
		if (!container) {
			// Prefer to use parentElement but add position-relative class rather than wrapping
			container = input.parentElement || input.parentNode;
			if (container && !container.classList.contains('position-relative')) {
				container.classList.add('position-relative');
			}
		}

		// if there's already a toggle in the same container, skip
		if (container.querySelector('.password-toggle')) return;

		// Ensure input has an id
		if (!input.id) {
			input.id = 'pw_' + Math.random().toString(36).slice(2, 9);
		}

		// Ensure input has padding on the right so text doesn't overlap icon
		if (!input.classList.contains('pe-5')) input.classList.add('pe-5');

		// Create button
		var btn = document.createElement('button');
		btn.type = 'button';
		btn.className = 'btn btn-sm password-toggle';
		btn.setAttribute('data-target', input.id);
		btn.setAttribute('aria-label', 'Hiện/ẩn mật khẩu');
		btn.setAttribute('aria-pressed', 'false');
		btn.innerHTML = '<i class="fas fa-eye"></i>';
		container.appendChild(btn);
	});

	// 2) Use event delegation to handle click for any .password-toggle
	document.addEventListener('click', function(e){
		var btn = e.target.closest('.password-toggle');
		if (!btn) return;
		e.preventDefault();
		var targetId = btn.getAttribute('data-target');
		if (!targetId) return;
		var input = document.getElementById(targetId);
		if (!input) return;
		console.log('Password toggle clicked for', targetId, 'current type=', input.type);
		var icon = btn.querySelector('i');
		if (input.type === 'password') {
			input.type = 'text';
			if (icon) { icon.classList.remove('fa-eye'); icon.classList.add('fa-eye-slash'); }
			btn.setAttribute('aria-pressed', 'true');
		} else {
			input.type = 'password';
			if (icon) { icon.classList.remove('fa-eye-slash'); icon.classList.add('fa-eye'); }
			btn.setAttribute('aria-pressed', 'false');
		}
		try { input.focus(); } catch(e){}
	});
});