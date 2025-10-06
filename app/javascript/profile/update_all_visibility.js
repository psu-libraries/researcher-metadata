export default function initUpdateAllVisibility() {
  const selectAllBtn = document.getElementById("select-all");
  if (!selectAllBtn) return;

  const checkboxes = () => Array.from(document.querySelectorAll(".visibility-toggle"));

  function updateButtonLabel() {
    const cbs = checkboxes();
    const noneChecked = cbs.length > 0 && cbs.every(cb => !cb.checked);
    selectAllBtn.textContent = noneChecked ? "Select All" : "Deselect All";
  }

  selectAllBtn.addEventListener("click", () => {
    const cbs = checkboxes();
    const noneChecked = cbs.every(cb => !cb.checked);
    const newState = noneChecked;

    cbs.forEach(cb => (cb.checked = newState));

    fetch("/presentation_contributions/bulk_update_visibility", {
      method: "PUT",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({ visible_in_profile: newState })
    });

    updateButtonLabel();
  });

  document.addEventListener("change", e => {
    if (e.target.matches(".visibility-toggle")) {
      updateButtonLabel();
    }
  });

  updateButtonLabel();
}
