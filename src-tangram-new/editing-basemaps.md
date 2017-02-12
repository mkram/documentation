<script>
function elementIntersectsViewport (el) {
  var top = el.offsetTop;
  var height = el.offsetHeight;

  while(el.offsetParent) {
    el = el.offsetParent;
    top += el.offsetTop;
  }

  return (
    top < (window.pageYOffset + window.innerHeight) &&
    (top + height) > window.pageYOffset
  );
}

function hide(el) {
    iframe = el.getElementsByTagName("iframe")[0];
    if (typeof iframe != "undefined") {
        try {
            if (typeof iframe.contentWindow.scene != 'undefined') {
                // make a new blob from the codemirror code
                var blob = new Blob([iframe.contentWindow.editor.getValue()], {type: "text/plain"});
                // make an objectURL from the blob and save that to the parent div
                el.setAttribute("code", window.URL.createObjectURL(blob));
                el.removeChild(iframe);
            }
        }
        catch(e) {
            console.log(e);
            el.removeChild(iframe);
        }
    }
}
function show(el) {
    if (typeof el != 'undefined') {
        iframe = el.getElementsByTagName("iframe")[0];
        if (typeof iframe == "undefined") {

            // create a new iframe
            iframe = document.createElement("iframe");
            iframe.classList.add("demoframe");
            var source = '';
            el.appendChild(iframe);

            // get the source if it has been set
            if (typeof el.getAttribute("source") != 'undefined') {
                // get the source
                source = el.getAttribute("source");
                if (el.getAttribute("code") !='' && el.getAttribute("code") !='null') {
                    // get source from the previously-saved blobURL
                    var code = el.getAttribute("code");
                    iframe.src = replaceUrlParam(el.getAttribute("source"), "scene", code);
                } else {
                    iframe.src = source;
                }
            }
        }
    }
}

function replaceUrlParam(url, param, value){
    var parser = document.createElement('a');
    parser.href = url;

    if (value == null) value = '';
    var pattern = new RegExp('\\b('+param+'=).*?(&|$)')
    if (parser.search.search(pattern)>=0){
        parser.search = parser.search.replace(pattern,'$1' + value + '$2');
    }
    return parser.href;
}


// check visibility every half-second, hide off-screen demos to go easy on the GPU
setInterval( function() {
    var elements = document.getElementsByClassName("demo");
    for (var i=0; i < elements.length; i++) {
        el = elements[i];
        if (elementIntersectsViewport(el) || (i == 0 && window.pageYOffset < 500)) {
            show(el);
            // show the next two iframes as well
            show(elements[i+1]);
            show(elements[i+2]);
            for (var j=0; j < elements.length; j++) {
                // don't hide the previous one, the current one, or the next two
                if (j != i && j != i-1 && j != i+1 && j != i+2) {
                    hide(elements[j]);
                }
            }
            break;
        }
    }
}, 500);
</script>
<style>
.demo-wrap {
    margin: 1em 0;
}
.demo {
    width: 100%;
    height: 400;
}
.demoframe {
    border: 0px;
    margin: 0;
    height: 100%;
    width: 100%;
}
.CodeMirror {
    width: 100%;
}
</style>

Mapzen has published a number of stylish yet functional [basemaps](https://mapzen.com/products/maps/), equally suitable for the home or office. They can be used as standalone Leaflet layers using [Mapzen.js](https://mapzen.com/documentation/mapzen-js/):

```javascript
var map = L.Mapzen.map('map', {
  center: [40.74429, -73.99035],
  zoom: 15,
  scene: L.Mapzen.BasemapStyles.Refill
})
```

Or, you can put your own data on top of them inside of a [Tangram](https://mapzen.com/products/tangram/) scene file with the `import` feature:

<div class="demo-wrap">
    <div class="demo" id="demo0" code="" source="https://precog.mapzen.com/tangrams/tangram-play/master/embed/?go=👌&scene=https://tangrams.github.io/tangram-docs/tutorials/editing-basemaps/editing-basemaps1.yaml#5/38.720/-79.717"></div>
    <span class="caption"><a target="_blank" href="http://mapzen.com/tangram/play/?scene=https://tangrams.github.io/tangram-docs/tutorials/editing-basemaps/editing-basemaps1.yaml#5/38.720/-79.717">( Open in Play ▶ )️</a></span>
</div>

But what do you do if you want to customize the house style itself? This is a bit trickier, and involves a bit of detective work.

First, you must know which features you wish to modify. The broader the class of features you want to change, the trickier it will be to change them. In our house styles, a given feature may be affected by multiple styles and sets of drawing rules, specifying a slightly different style at various zoom levels, and for various sub-classifications of the data. So, once you've picked a feature, you must understand how that feature is currently drawn.

## Basic Style Override

Before we start pulling apart a house style, let's start with a simpler example to see the basic method to override a style. Here's a very basic Tangram scene file:

<div class="demo-wrap">
    <div class="demo" id="demo1" code="" source="https://precog.mapzen.com/tangrams/tangram-play/master/embed/?go=👌&scene=https://tangrams.github.io/tangram-docs/tutorials/editing-basemaps/simple-basemap.yaml#11.8002/41.3381/69.2698"></div>
    <span class="caption"><a target="_blank" href="http://mapzen.com/tangram/play/?scene=https://tangrams.github.io/tangram-docs/tutorials/editing-basemaps/simple-basemap.yaml#11.8002/41.3381/69.2698">( Open in Play ▶ )️</a></span>
</div>

We've saved this scene file to the Tangram documentation repo, so it can be imported as a base style in a Tangram scene file, like so:

```yaml
import: https://tangrams.github.io/tangram-docs/tutorials/editing-basemaps/simple-basemap.yaml
```

Then, to modify it, identify the parameter you want to change, and then re-declare its whole branch, back to the root level. This will tell Tangram exactly which node you want to overwrite.

In this case, we'll change the `color` of the `major_road` sublayer. We don't need to include any of the other parameters in that layer, unless we want to change them – they already exist in the imported style, and will still take effect. Simple enough!

<div class="demo-wrap">
    <div class="demo" id="demo3" code="" source="https://precog.mapzen.com/tangrams/tangram-play/master/embed/?go=👌&scene=https://tangrams.github.io/tangram-docs/tutorials/editing-basemaps/editing-basemaps3.yaml#11.8002/41.3381/69.2698"></div>
    <span class="caption"><a target="_blank" href="http://mapzen.com/tangram/play/?scene=https://tangrams.github.io/tangram-docs/tutorials/editing-basemaps/editing-basemaps3.yaml#11.8002/41.3381/69.2698">( Open in Play ▶ )️</a></span>
</div>

## Customizing a House Style

The Mapzen house styles are significantly more complex. Take the case of [Refill](https://github.com/tangrams/refill-style), which is deceptively simple-looking – though it is monochrome, this style includes dozens of places where road color is specified, depending on the classification of road, its datasource, even the zoom level at which it's drawn. This means you'll have to change color values in many places.

So let's try it. First, open up the Refill style and take a look at it: https://github.com/tangrams/refill-style/blob/gh-pages/refill-style.yaml

Then, open it in a separate text editor, so you can easily navigate around. Then, search for the roads layer, which can be found by searching for `roads:` – it starts like this:

```yaml
roads:
        data: { source: mapzen, layer: roads }
        filter: { not: { kind: rail } }
        draw:
            lines:
            ...
```

Copy the entire "roads" layer into an editor somewhere – it could be Tangram Play, or the text editor of your choice. Tangram Play has a "select similar" feature, accessed by pressing `control-D`, which will find the next instance of the selected text and add to the selection. This allows you to edit in multiple places at once, which comes in handy for the next step.

Now, we want to delete any branch which doesn't end with a `lines: color:` – so all of the `filter` declarations, and `width` declaration, even the `outline` declarations: all of those and their descendants can be deleted.

So this block:

```yaml
minor_road:
    filter: { kind: minor_road }
    draw:
        lines:
            color: [[12, global.minor_road1], [17, global.minor_road2]]
            width: [[12, 1.0px], [14, 1.5px], [15, 3px], [16, 5m]]
            outline:
                width: [[12, 0px], [14, .5px], [17, 1px]]
```

Would become this:

```yaml
minor_road:
    draw:
        lines:
            color: [[12, global.minor_road1], [17, global.minor_road2]]
```

Then, change all of the color values to something festive. Red is a classic choice:

```yaml
minor_road:
    draw:
        lines:
            color: red
```

As of this writing, the roads layer is almost 1400 lines long, but after editing, it should be closer to 200 – and all made up of `color` declarations. When you have that, paste it into your new scene file under the `import`, and all of those color declarations will overwrite the ones in the import.

Here's an example scene file: https://github.com/tangrams/tangram-docs/blob/gh-pages/tutorials/editing-basemaps/editing-basemaps4.yaml

And here's what it looks like:

<div class="demo-wrap">
    <div class="demo" id="demo4" code="" source="https://precog.mapzen.com/tangrams/tangram-play/master/embed/?go=👌&scene=https://tangrams.github.io/tangram-docs/tutorials/editing-basemaps/editing-basemaps4.yaml#11.8002/41.3381/69.2698"></div>
    <span class="caption"><a target="_blank" href="http://mapzen.com/tangram/play/?scene=https://tangrams.github.io/tangram-docs/tutorials/editing-basemaps/editing-basemaps4.yaml#11.8002/41.3381/69.2698">( Open in Play ▶ )️</a></span>
</div>

Congratulations! Those are the basics of customizing an imported scene file. In fact there's no advanced technique, that's it.

Questions? Comments? Drop us a line [on GitHub](http://github.com/tangrams/tangram/issues), [on Twitter](http://twitter.com/tangramjs), or [via email](mailto:tangram@mapzen.com).