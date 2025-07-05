document.getElementById('toggle-aceite').addEventListener('click', function() {
  const button = this;
  const currentStatus = button.getAttribute('data-status');
  const newStatus = currentStatus === 'on' ? 'off' : 'on';

  fetch('/admin/toggle_aceite_automatico', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
    },
    body: `status=${newStatus}`
  })
  .then(response => response.json())
  .then(data => {
    button.setAttribute('data-status', newStatus);
    button.textContent = `Aceite automático ${newStatus.toUpperCase()}`;
    button.classList.toggle('btn-success');
    button.classList.toggle('btn-outline-secondary');
  });
}); 