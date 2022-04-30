const url = new URL(Deno.args[0]);
// console.log(url.toString());
// console.log(url.search);
// url.search = new URLSearchParams(url.search).toString();
// console.log(url.search);
const res = await fetch(url);
const json = await res.json();
// const body = new Uint8Array(await res.arrayBuffer());
// const json = JSON.parse(body);
// await Deno.stdout.write(res.json());
console.log(json);

const util = {};
// https://betterprogramming.pub/compose-and-pipe-in-javascript-medium-d1e1b2b21f83
util.pipe =
  function(...functions) {
    return function(x) {
      return functions.reduce( (acc, fn) => fn(acc), x);
    }
  }

function cullItemProps(item) {

  const neededKeys =
    [ 'description'
    , 'disclaimer'
    , 'name'
    , 'page'
    , 'post_price_text'
    , 'pre_price_text'
    , 'price_text'
    , 'sale_story'
    ]
  ;

  const doFilter =
    //   function(accObj, currentKey) {
    //     accObj[currentKey] = item[currentKey];
    //     return accObj;
    //   }
    // or
    (accObj, currentKey) => ({ ...accObj, [currentKey]: item[currentKey] })
  ;

  return neededKeys.reduce(doFilter, {});
}

// TODO: Make it SSML instead?
function sanitizeAndStringifyProps(item) {

  return item.name
       + ", "
       + (item.description ?? "")
         .replaceAll("\n", " ")
         .replaceAll("-oz.", " ounce")
         .replace("ea.", "each")
       + ", "
       + item.pre_price_text
       + (item.price_text ? ` \$${item.price_text}` : "")
       + " "
       + (item.post_price_text ?? "")
         .replace(/^ea.*$/, "each, member price")
         .replace(/^lb.*$/, "per pound, member price")
       + ". "
       + (item.sale_story ?? "")
         .replace(/member price/i, "")
       + ". "
       + (item.disclaimer ?? "")
         .split("\n")
         .sort()
         .filter(line => !line.match(/for u/i))
         .filter(line => line.length)
         .join(". ")
         // to filter out lines like
         // "Safeway   for  U™   coupon  must
         //  be  present  at   check  out  or
         //  downloaded to your account prior
         //  to  purchase.  LIMIT ONE  Coupon
         //  per  Household per  Day. Expires
         //  1/25/22."
       ;
}

// TODO: Add transformation function as inputs (e.g., sanitizeAndStringifyProps)
function transfromItemsAndArrangeThemByCategory(items) {
  // const category = currentItem.categories.join('|');
  // TODO: disclaimer prop string needs to be filtered too...

  const toCategories =
    function (accObj, currentItem) {

      const category =
        currentItem
        .categories
        .filter(e => e !== "Coupon")
        .join()
      ;

      if (!accObj.hasOwnProperty(category)) {
        accObj[category] = [];
      }

      const transformAndPush =
        util.pipe
          ( cullItemProps
          , sanitizeAndStringifyProps
          , transformedItem => accObj[category].push(transformedItem)
          , _ => accObj
          )
      ;

      return transformAndPush(currentItem);
    }

  return items.reduce(toCategories, {});
}

// let g = f.reduce(transfromItemsAndArrangeThemByCategory, {});
let g =
  util.pipe
    ( items => items.filter( item => item.categories.length )
    , transfromItemsAndArrangeThemByCategory
    )
    (f)
;

// To compare the number of items in `f` and `g`:
// Object.keys(g).reduce( (acc, key) => acc + g[key].length, 0)

// TODO: define recording headers

Object.keys(g).reduce( (accArr, categoryKey) => { accArr.push(`Current category: ${categoryKey}. ` + g[categoryKey].join(" ") + `End of ${categoryKey}.`); return accArr }, []).join(" ")
