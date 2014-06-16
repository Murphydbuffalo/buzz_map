$(document).ready(function() {

    var foundCounties = "Mineral, NV";

    var searchTerm = "ruby";

    var nation = null;
    var counties = null;

    nation = d3.select("svg");
    counties = nation.selectAll("data-label");

    counties = $("path").map(function() {
        return $(this).data("label");
    }).get();

    $('path[data-label = "' + foundCounties + '"]').css({
        'fill': 'red'
    });

    // counties = nation.getAttribute("data"[label];

    // for (var i = 0; i < statePaths.length; i++) {
    //     if (statePaths[i].id.length == 2) {
    //         stateAbbreviations.push(statePaths[i].id);
    //     }
    // }

    // recolorNation(dominantHashtagAt(SOTUvideo.currentTime)); /
});
