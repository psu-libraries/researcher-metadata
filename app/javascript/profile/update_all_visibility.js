export default function updateAllVisibility() {
  const selectAllBtn = document.getElementById("select-all");
  const deselectAllBtn = document.getElementById("deselect-all");
  const checkboxes = () => Array.from(document.querySelectorAll(".visibility-toggle"));

  selectAllBtn.addEventListener("click", () => {
    checkboxes().forEach(cb => (cb.checked = true));
    selectAllBtn.style.display = "none";
    deselectAllBtn.style.display = "inline-block";
  });

  deselectAllBtn.addEventListener("click", () => {
    checkboxes().forEach(cb => (cb.checked = false));
    deselectAllBtn.style.display = "none";
    selectAllBtn.style.display = "inline-block";
  });
}
