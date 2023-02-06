const file_version_polling = () => {
    const fileVersionResult = document.getElementById("file_version_result");
    if(fileVersionResult) {
        const targetUrl = fileVersionResult.getAttribute("data-target");

        var polling = setInterval(function() {
            if(targetUrl) {
                fetch(targetUrl)
                    .then(response => response.text())
                    .then(result => {
                        if(result) {
                            document.getElementById("file_version_result").innerHTML = result;
                            
                            clearInterval(polling);
                        }
                    });
                }
        }, 2000);

        // Stop the poll after 60 seconds
        setTimeout(function() { 
            clearInterval(polling);
        }, 60000);
    }
}

export default file_version_polling;