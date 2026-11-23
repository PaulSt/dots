// Use Sioyek's layout calculations for both single pages and double-page spreads.
(function () {
    var original = sioyek_api.get_json_state();
    if (!original.document_path) return;

    sioyek.fit_to_page_height();
    sioyek.fit_to_page_width();
    var centered = sioyek_api.get_json_state();

    // Restore zoom first, then position: changing zoom can readjust the offsets.
    sioyek_api.set_state({ zoom_level: original.zoom_level });
    sioyek_api.goto_offset(centered.x_offset, centered.y_offset);
})();
