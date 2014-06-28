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

        var search_term = window.search_term;

        var counties = window.counties;

        $('path').data("count", 0);

        for (i in counties) {

            $('path[data-label = "' + counties[i] + '"]').css({
                'fill': 'rgba(152,204,150,' + (counties[i]["count"] * .05) + ')'
            });

            $('path[data-label = "' + counties[i] + '"]').data(
                "count", 1
            );

            total_tweets += 1;

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
