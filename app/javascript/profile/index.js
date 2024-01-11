require("@nathanvda/cocoon")
import $ from 'jquery'

window.jQuery = $;
window.$ = $;

import "./profile_page";
import "./manage";
import file_version_polling from "./file_version_polling";

document.addEventListener("DOMContentLoaded", function () {
    file_version_polling();
});
