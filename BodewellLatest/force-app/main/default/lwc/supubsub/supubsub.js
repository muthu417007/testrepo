const events = {};
var translationObject = {};

/**
* Registers a callback for an event
* @param {string} eventName - Name of the event to listen for.
* @param {function} callback - Function to invoke when said event is fired.
* @param {object} thisArg - The value to be passed as the this parameter to the callback function is bound.
*/
const registerListener = (eventName, callback, thisArg) => {

    if (!events[eventName]) {
        events[eventName] = [];
    }

    const duplicate = events[eventName].find(listener => {
        return listener.callback === callback && listener.thisArg === thisArg;
    });

    if (!duplicate) {
        events[eventName].push({ callback, thisArg });
    }
};

/**
* Unregisters a callback for an event
* @param {string} eventName - Name of the event to unregister from.
* @param {function} callback - Function to unregister.
* @param {object} thisArg - The value to be passed as the this parameter to the callback function is bound.
*/
const unregisterListener = (eventName, callback, thisArg) => {
    if (events[eventName]) {
        events[eventName] = events[eventName].filter(
            listener =>
            listener.callback !== callback || listener.thisArg !== thisArg
        );
    }
};

/**
* Unregisters all event listeners bound to an object.
* @param {object} thisArg - All the callbacks bound to this object will be removed.
*/
const unregisterAllListeners = thisArg => {
    Object.keys(events).forEach(eventName => {
        events[eventName] = events[eventName].filter(
            listener => listener.thisArg !== thisArg
        );
    });
};

/**
* Fires an event to listeners.
* @param {object} pageRef - Reference of the page that represents the event scope.
* @param {string} eventName - Name of the event to fire.
@param {} payload - Payload of the event to fire.
*/
const fireEvent = (pageRef, eventName, payload ) => {
    if (events[eventName]) {
        const listeners = events[eventName];
        listeners.forEach(listener => {
            try {
                listener.callback.call(listener.thisArg, payload);
            } catch (error) {
            // fail silently
            }
        });
    }
};

const sortMergeFacet = (filters, sort) => {
    let sortBy = sort.split('_')[0];
    let orderBy = sort.split('_')[1];
    if (sortBy === 'term') filters = filters.sort(function(a, b) { 
        return ( (a.displayNameFrontend || a.ContentnameFrontend) > (b.displayNameFrontend || b.ContentnameFrontend)
            ? 1
            : (a.displayNameFrontend || a.ContentnameFrontend) < (b.displayNameFrontend || b.ContentnameFrontend)
                ? -1
                : 0
            )
    })
    if (sortBy === 'count') filters = filters.sort(function(a, b) {return a.value - b.value});
    if (orderBy === 'desc') filters = filters.reverse();
    let arr = [];
    return(filters.filter(function(f) {
        if (f.selected) return f; 
        arr.push(f);
    }).concat(arr));
}

const mergeFilters = (h, aggrData, isSearched, self) => {
    let k = -1;
    let existingIndex = -1;
    aggrData.some(function(f, i) { if (f.key == h.facetName) { k = i; return true; } });
    if (k == -1) return [];
    let exists = aggrData.length > 0 ? aggrData[k].values.filter(function(f,i) { if( f.Contentname == 'merged_'+h.filterNewName) { existingIndex = i; return true;} }) : [];
    let children = exists.length ? aggrData[k].values[existingIndex].childArray.map(function(f){return f.Contentname}) : [];

    if (isSearched) {
        let filtersToAdd = self.aggregationsData.filter(function(f) {return f.key == h.facetName})[0].values.find(function (n) { return n.Contentname == 'merged_' + h.filterNewName});
        if (filtersToAdd)
            filtersToAdd.childArray.forEach(function(filter) {
                if(children.indexOf(filter.Contentname) == -1) {
                    aggrData[k].values.push(filter);
                }
            })
    }

    h.filterList = h.filterList.map(function(filter) { return decodeURIComponent(filter)});
    let l = k > -1 ? aggrData[k].values.filter(function(f) { return h.filterList.indexOf(f.Contentname) > -1 && children.indexOf(f.Contentname) == -1 }) : [];
    let v = 0;
    l.forEach(function(f) {
        v += f.value;
    });

    if (l.length) {
        let place = aggrData[k].values.length;
        aggrData[k].merged = true;
        let childArray = [];
        let s = JSON.parse(JSON.stringify(l[0]));
        l.forEach(function (f, ind) {
            let index = -1;
            aggrData[k].values.some(function (d, i) { if (d.Contentname == f.Contentname) { index = i; return true; } });
            if (index > -1) {
                childArray.push(aggrData[k].values[index]);
                if (index < place) place = index;
                let regex = isSearched ? new RegExp(".*" + self.pagingAggregation.keyword + ".*", 'gi') : '';
                console.log('--- ',(isSearched && !regex.test(aggrData[k].values[index].Contentname)));
                            if ( (index > -1 && !isSearched) || (isSearched && !regex.test(aggrData[k].values[index].Contentname))) aggrData[k].values.splice(index, 1);
            } else {
                s = {};
                ind = h.filterList.indexOf(f);
                let displayName = h.filterDisplayName[ind];
                let filterobj = {
                    "displayName": displayName,
                    "Contentname": f.Contentname || f,
                    "parent": h.facetName,
                    "value": 0
                }
                childArray.push(filterobj);
            }
        });

        childArray.forEach(function(f) { f.immediateParent = 'merged_' + h.filterNewName;
            f.level = 2;
            f.parent = h.facetName;
            f.childName = f.Contentname;
            f.displayName = f.displayName || f.Contentname;
        });
        let exists = aggrData[k].values.filter(function(f,i) { if( f.Contentname == 'merged_'+h.filterNewName) { existingIndex = i; return true;}  });
        if (existingIndex == -1) {
            s.displayName = h.filterNewName;
            s.Contentname = 'merged_' + h.filterNewName;
            s.displayNameFrontend = h.filterNewName;
            s.ContentnameFrontend = 'merged_' + h.filterNewName;
            s.Contentname_short = h.filterNewName;
            s.value = isSearched ? null : v;
            s.level = 1;
            s.merged = true;
            s.showChild = parseInt(h.showChild ? h.showChild : '0');
            s.selected = false;
            s.filterList = h.filterList;
            s.indeterminate = false;
            s.childArray = JSON.parse(JSON.stringify(childArray));
            s.childSelected = childArray.some(f => f.selected);
            s.displayNameAvailable = true;
            if (s.childArray) {
                Object.assign(s, { 'collapseExampleID': 'collapseExample-' + aggrData[k].key +'_'+ s.Contentname + '_icon' });//{!'collapseExample-'+s.key+'_icon'}
                Object.assign(s, { 'collapseExampletoggleIconID': 'collapseExample-' + aggrData[k].key +'_'+ s.Contentname + '_toggleIconOn' });//{!'collapseExample-'+s.key+'_toggleIconOn'}
                Object.assign(s, { 'collapseExampletoggleIconOffID': 'collapseExample-' + aggrData[k].key +'_'+ s.Contentname + '_toggleIconOff' });//{!'collapseExample-'+s.key+'_toggleIconOn'}
                Object.assign(s, { 'collapseExampleEmptyID': 'collapseExample-' + aggrData[k].key +'_'+ s.Contentname });
            }
            var aggregations=JSON.parse(self.selectedTypeFilter || '[]');
            if (aggregations.length != 0) {
                let index = -1;
                aggregations.some(function (facet, i) { if (facet.type == h.facetName) { index = i; return true; } });
                if (index >= 0) {
                    var filtersInAggr;
                    let existingChildren = l.map(function(c) { return c.Contentname} )
                    if (aggregations[index] && aggregations[index].filter && aggregations[index].filter.length) {
                        filtersInAggr = aggregations[index].filter.filter(function (ele) {
                            return existingChildren.indexOf(ele) > -1
                        })
                        if (filtersInAggr.length == existingChildren.length){
                            s.selected = true;
                        } else if(filtersInAggr.length) {
                            s.indeterminate =  true;
                        }
                    }
                }
            }
            aggrData[k].values.splice(place, 0, s);
            aggrData[k].values = aggrData[k].sort && aggrData[k].sort != 'custom' ? sortMergeFacet(aggrData[k].values, aggrData[k].sort) : aggrData[k].values;
        }
        else {
            aggrData[k].values[existingIndex].value += v;
            aggrData[k].values[existingIndex].childArray = aggrData[k].values[existingIndex].childArray.concat(childArray);
        }
    }
};

translationObject = {
        "All_Content": "All Content",
        "Log out": "Log out",
        "Edit Page Layout": "Edit Page Layout",
        "Reset": "Reset",
        "Apply Changes": "Apply Changes",
        "Pre Select a Tab": "Pre Select a Tab",
        "Search Result": "Search Result",
        "What is Lorem Ipsum?": "What is Lorem Ipsum?",
        "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.": "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.",
        "Answered": "Answered",
        "Rearrange Facets": "Rearrange Facets",
        "sort filter": "sort filter",
        "Bookmark your search": "Bookmark your search",
        "Title for this search": "Title for this search",
        "Without the words": "Without the words",
        "With one or more words": "With one or more words",
        "With the exact phrase": "With the exact phrase",
        "Show": "Show",
        "Hide": "Hide",
        "Filters": "Filters",
        "Filters To Left": "Filters To Left",
        "Filters To Right": "Filters To Right",
        "Search here": "Search here",
        "more": "more",
        "true": "true",
        "Created Date": "Created Date",
        "Enter search terms in one or all the boxes": "Enter search terms in one or all the boxes",
        "Results per page": "Results per page",
        "results": "results",
        "Refine Search": "Refine Search",
        "Saved Bookmarks": "Saved Bookmarks",
        "Oops": "Oops",
        "There is nothing here. Zilch. Return to search": "There is nothing here. Zilch. Return to search",
        "and create your first bookmark": "and create your first bookmark",
        "Remove Bookmark": "Remove Bookmark",
        "Save as Bookmark": "Save as Bookmark",
        "Save": "Save",
        "You can bookmark upto 20 searches": "You can bookmark upto 20 searches",
        "Advanced Search": "Advanced Search",
        "Save Bookmark": "Save Bookmark",
        "Show Bookmark": "Show Bookmark",
        "Language": "Language",
        "Sort By": "Sort By",
        "List View": "List View",
        "Grid View": "Grid View",
        "Custom": "Custom",
        "background": "background",
        "Alphabetically (a-z)": "Alphabetically (a-z)",
        "Alphabetically (z-a)": "Alphabetically (z-a)",
        "Count (asc)": "Count (asc)",
        "Count (desc)": "Count (desc)",
        "Show more": "Show more",
        "Show less": "Show less",
        "Did you mean": "Did you mean",
        "Showing page": "Showing page",
        "of": "of",
        "total": "total",
        "seconds": "seconds",
        "Filter": "Filter",
        "Clear all filters": "Clear all filters",
        "Clear all": "Clear all",
        "See": "See",
        "See less": "See less",
        "Show all": "Show all",
        "Was above result helpful": "Was above result helpful",
        "Thank you for your response": "Thank you for your response",
        "Auto tuned": "Auto tuned",
        "Attach To Case Comment": "Attach To Case Comment",
        "Kudos": "Kudos",
        "Views": "Views",
        "Replies": "Replies",
        "Was above result helpful": "Was above result helpful",
        "Similar Searches": "Similar Searches",
        "Recommendations / Useful Articles": "Recommendations / Useful Articles",
        "Narrow your search": "Narrow your search",
        "Search Tips": "Search Tips",
        "Customize": "Customize",
        "Enter just a few key words related to your question or problem": "Enter just a few key words related to your question or problem",
        "Add Key words to refine your search as necessary": "Add Key words to refine your search as necessary",
        "Do not use punctuation": "Do not use punctuation",
        "Search is not case sensitive": "Search is not case sensitive",
        'Avoid non-descriptive filler words like "how", "the", "what", etc': 'Avoid non-descriptive filler words like "how", "the", "what", etc',
        "If you do not find what you are looking for the first time,reduce the number of key words you enter and try searching again": "If you do not find what you are looking for the first time,reduce the number of key words you enter and try searching again",
        "Minimum supported Internet Explorer version is IE9": "Minimum supported Internet Explorer version is IE9",
        "Search": "Search",
        "Bookmarks": "Bookmarks",
        "Tips": "Tips",
        "Page Top": "Page Top",
        "Click here to clear filters and perform a fresh search": "Click here to clear filters and perform a fresh search",
        "Sorry no results found": "Sorry no results found",
        "Showing results using some of your recent search terms": "Showing results using some of your recent search terms",
        "Saved successfully": "Saved successfully",
        "Agent Helper": "Agent Helper",
        "KCS Enabler": "KCS Enabler",
        "SearchUnify": "SearchUnify",
        "Choose a Template": "Choose a Template",
        "Data Categories": "Data Categories",
        "Channels": "Channels",
        "Edit Article": "Edit Article",
        "Access Control and Other Settings": "Access Control and Other Settings",
        "New Article": "New Article",
        "More Articles": "More Articles",
        "Please check KCS configurations in Admin Panel": "Please check KCS configurations in Admin Panel",
        "Edit": "Edit",
        "Manage":"Manage",
        "My Draft Articles": "My Draft Articles",
        "Create New Article": "Create New Article",
        "No Result Found": "No Result Found",
        "Page": "Page",
        "Keyword": "Keyword",
        "Type of event": "Type of event",
        "click": "click",
        "Views": "Views",
        "Searches": "Searches",
        "Top Articles Used in Similar cases": "Top Articles Used in Similar cases",
        "Top agents solved similar cases": "Top agents solved similar cases",
        "Top Related Cases": "Top Related Cases",
        "Top Experts":"Top Experts",
        "Top Articles": "Top Articles",
        "Cases": "Cases",
        "Experts": "Experts",
        "Articles": "Articles",
        "User journey": "User journey",
        "Link Copied to Clipboard": "Link Copied to Clipboard",
        "Article attached successfully": "Article attached successfully",
        "Article detached successfully": "Article detached successfully", 
        "Attachments": "Attachments",
        "Attach article to case": "Attach article to case",
        "Detach article to case": "Detach article to case",
        "Send Link as Email": "Send Link as Email",
        "Send Link as Case Comment": "Send Link as Case Comment",
        "View All": "View All",
        "Active Case": "Active Case",
        "Show Results": "Show Results",
        "Search is not working. Please try again": "Search is not working. Please try again",
        "Selected Filters": "Selected Filters",
        "'We're sorry. We Cannot find any matches for your search term": "'We're sorry. We Cannot find any matches for your search term",
        "Copied To Clipboard":"Copied To Clipboard",
    }

const updateTranslation = (language, changeLang) => {
    language = JSON.parse(language);
    translationObject = {
        ...translationObject,
        ...(language[changeLang] ? language[changeLang || language.config.defaultLanguage.code].mapping : language['en'].mapping)
    };
    for(var key in translationObject){
        let newKey = key.replace(new RegExp(/[/\W|_/]/gi), '_')
        if (translationObject[key]) {
            translationObject[newKey] = translationObject[key];
        }
    }
};

export {
    registerListener,
    unregisterListener,
    unregisterAllListeners,
    fireEvent,
    mergeFilters,
    updateTranslation,
    translationObject
};