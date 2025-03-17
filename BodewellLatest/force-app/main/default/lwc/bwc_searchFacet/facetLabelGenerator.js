import labels from './labels';

/**
 * @param {boolean} expanded Whether the facet is expanded or not
 * @returns {string}
 *  A localized label for the toggled state of the facet.
 */
export default function generateLabel(expanded) {
    return expanded ? labels.toggleFilterExpandedAssistiveText : labels.toggleFilterCollapsedAssistiveText;
}