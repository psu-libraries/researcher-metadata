require("@nathanvda/cocoon")
import $ from 'jquery'

import 'webpack-jquery-ui/css'
import 'webpack-jquery-ui/sortable'

window.jQuery = $;
window.$ = $;

import "./profile_page";
import "./manage";
import file_version_polling from "./file_version_polling";

document.addEventListener("DOMContentLoaded", function () {
    file_version_polling();
});
