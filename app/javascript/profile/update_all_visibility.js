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
    console.log("Update checkboxes");
    updateButtonLabel();
    console.log("Update button label");
    
    fetch("/presentation_contributions/bulk_update_visibility", {
      method: "PUT",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({ visible_in_profile: newState })
    }).then(response => {
      console.log("Response status:", response.status);
      console.log("Response ok?:", response.ok);
      return response.text();
    }).then(body => {
      console.log("Response body:", body);
    }).catch(err => {
      console.error("Fetch error:", err);
    });
    console.log("SQL Query");
    
  });

  document.addEventListener("change", e => {
    if (e.target.matches(".visibility-toggle")) {
      updateButtonLabel();
    }
  });

  updateButtonLabel();
}
