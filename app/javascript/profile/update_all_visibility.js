export default function updateAllVisibility() {
  const selectAllBtn = document.getElementById("select-all");
  const deselectAllBtn = document.getElementById("deselect-all");
  const checkboxes = () => Array.from(document.querySelectorAll(".visibility-toggle"));

  selectAllBtn.addEventListener("click", () => {
    checkboxes().forEach(cb => (cb.checked = true));
  });

  deselectAllBtn.addEventListener("click", () => {
    checkboxes().forEach(cb => (cb.checked = false));
  });
}
