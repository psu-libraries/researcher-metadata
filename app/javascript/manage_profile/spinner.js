export const spinner = () => {
    const innerSpinnerHTML = `<div class="spinner-border spinner-border-sm text-secondary" role="status">
                                  <span class="sr-only">Loading...</span>
                              </div>`;
    let spinElement = document.createElement('div');
    spinElement.classList.add('rmd-spinner');
    spinElement.innerHTML = innerSpinnerHTML;

    return spinElement;
};