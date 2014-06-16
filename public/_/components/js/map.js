$(document).ready(function() {

    var main = d3.select("body").append("article");

    var svg;

    // load SVG XML into DOM with D3
    d3.xml("images/US_Counties.svg", function(error, documentFragment) {
        if (error) {
            console.log(error);
            return;
        }

        // select SVG tag itself within loaded document
        var svgNode = documentFragment.getElementsByTagName("svg")[0];

        // append SVG as child to article tag
        main.node().appendChild(svgNode);


        nation = main.select("svg").selectAll("path").
        style({
            'stroke': '#004563',
            'stroke-width': .2
        });

        var counties = [{
            county: "Mineral, NV",
            value: 20
        }, {
            county: "Boone, NE",
            value: 10
        }, {
            county: "Stanton, NE",
            value: 30
        }, {
            county: "Forrest, MS",
            value: 40
        }, {
            county: "Pike, MS",
            value: 30
        }, {
            county: "Washington, DC",
            value: 100
        }, {
            county: "Fremont, WY",
            value: 10
        }, {
            county: "Charlotte, FL",
            value: 10
        }, {
            county: "Bon Homme, SD",
            value: 10
        }, {
            county: "Yankton, SD",
            value: 12
        }, {
            county: "Hutchinson, SD",
            value: 20
        }, {
            county: "Hanson, SD",
            value: 90
        }, {
            county: "Prentiss, MS",
            value: 10
        }, {
            county: "Tishomingo, MS",
            value: 10
        }, {
            county: "Alcorn, MS",
            value: 1
        }, {
            county: "Tippah, MS",
            value: 34
        }, {
            county: "Cheboygan, MI",
            value: 2
        }, {
            county: "Emmet, MI",
            value: 5
        }, {
            county: "Mackinac, MI",
            value: 30
        }, {
            county: "Chippewa, MI",
            value: 20
        }, {
            county: "Luce, MI",
            value: 22
        }, {
            county: "Stafford, VA",
            value: 9
        }, {
            county: "King George, VA",
            value: 12
        }, {
            county: "Westmoreland, VA",
            value: 18
        }, {
            county: "Northumberland, VA",
            value: 2
        }, {
            county: "Mathews, VA",
            value: 7
        }, {
            county: "Norfolk, VA",
            value: 50
        }, {
            county: "Isle of Wight, VA",
            value: 40
        }, {
            county: "Suffolk, VA",
            value: 10
        }, {
            county: "Chesapeake, VA",
            value: 5
        }];


        var searchTerm = "ruby";

        // counties = $("path").map(function() {
        //     return $(this).data("label");
        // }).get();

        for (i in counties) {

            $('path[data-label = "' + counties[i]["county"] + '"]').css({
                'fill': 'rgba(152,204,150,' + (counties[i]["value"] * .05) + ')'
            });
        }
    });
    // counties = nation.getAttribute("data" [label];


    // });



    // var foundCounties = "Mineral, NV";

    // var searchTerm = "ruby";

    // var nation = null;
    // var counties = null;

    // nation = d3.select("svg");
    // counties = nation.selectAll("data-label");

    // counties = $("path").map(function() {
    //     return $(this).data("label");
    // }).get();

    // $('path[data-label = "' + foundCounties + '"]').css({
    //     'fill': 'red'
    // });

    // counties = nation.getAttribute("data"[label];

    // for (var i = 0; i < statePaths.length; i++) {
    //     if (statePaths[i].id.length == 2) {
    //         stateAbbreviations.push(statePaths[i].id);
    //     }
    // }

    // recolorNation(dominantHashtagAt(SOTUvideo.currentTime)); /
});
