require("@nathanvda/cocoon")
import $ from 'jquery'

window.jQuery = $;
window.$ = $;

import "./profile_page";
import "./manage";
import updateAllVisibility from './update_all_visibility';

document.addEventListener("DOMContentLoaded", function () {
    updateAllVisibility();
});
