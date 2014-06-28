$(document).ready(function() {

    var main = d3.select("body").append("article");

    var svg;

    var total_tweets = 0;

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


        countyLines = main.select("svg").selectAll("path").
        style({
            'stroke': '#004563',
            'stroke-width': .2
        });

        var counties = [{
            county: "Mineral, NV",
            count: 20
        }, {
            county: "Boone, NE",
            count: 10
        }, {
            county: "Stanton, NE",
            count: 30
        }, {
            county: "Forrest, MS",
            count: 40
        }, {
            county: "Pike, MS",
            count: 30
        }, {
            county: "Washington, DC",
            count: 100
        }, {
            county: "Fremont, WY",
            count: 10
        }, {
            county: "Charlotte, FL",
            count: 10
        }, {
            county: "Bon Homme, SD",
            count: 10
        }, {
            county: "Yankton, SD",
            count: 12
        }, {
            county: "Hutchinson, SD",
            count: 20
        }, {
            county: "Hanson, SD",
            count: 90
        }, {
            county: "Prentiss, MS",
            count: 10
        }, {
            county: "Tishomingo, MS",
            count: 10
        }, {
            county: "Alcorn, MS",
            count: 1
        }, {
            county: "Tippah, MS",
            count: 34
        }, {
            county: "Cheboygan, MI",
            count: 2
        }, {
            county: "Emmet, MI",
            count: 5
        }, {
            county: "Mackinac, MI",
            count: 30
        }, {
            county: "Chippewa, MI",
            count: 20
        }, {
            county: "Luce, MI",
            count: 22
        }, {
            county: "Stafford, VA",
            count: 9
        }, {
            county: "King George, VA",
            count: 12
        }, {
            county: "Westmoreland, VA",
            count: 18
        }, {
            county: "Northumberland, VA",
            count: 2
        }, {
            county: "Mathews, VA",
            count: 7
        }, {
            county: "Norfolk, VA",
            count: 50
        }, {
            county: "Isle of Wight, VA",
            count: 40
        }, {
            county: "Suffolk, VA",
            count: 10
        }, {
            county: "Chesapeake, VA",
            count: 5
        }];


        var search_term = <%= @search_term %> ;

        // counties = $("path").map(function() {
        //     return $(this).data("label");
        // }).get();

        $('path').data("count", 0);

        for (i in counties) {

            $('path[data-label = "' + counties[i]["county"] + '"]').css({
                'fill': 'rgba(152,204,150,' + (counties[i]["count"] * .05) + ')'
            });

            $('path[data-label = "' + counties[i]["county"] + '"]').data(
                "count", counties[i]["count"]
            );

            total_tweets += counties[i]["count"];

        }

        $('path[data-label = "America"]').data("count", total_tweets);

        $(".county-info").html(total_tweets + " tweets in America about " + '"' + search_term + '"');

        countyLines.on("mouseover", function() {
            var current_county = $(this).data("label");
            var current_count = $(this).data("count");
            var word_tweet = "tweet";
            if (current_count > 1 || current_count == 0) {
                word_tweet = "tweets";
            }

            d3.select(this).style("stroke-width", "2");
            $(".county-info").html(current_count + ' ' +
                word_tweet + " in " + current_county + " about " + '"' + search_term + '"');
        })
            .on("mouseout", function() {
                d3.select(this).style("stroke-width", ".2");
                $(".county-info").html(total_tweets + " tweets in America about " + '"' + search_term + '"');
            }).on("click", function() {
                d3.select(this).style("stroke-width", "2");
            });
    });

});
