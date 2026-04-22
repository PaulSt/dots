#include QMK_KEYBOARD_H

enum layers {
    _BASE,
    _FN,
};

#ifdef OLED_ENABLE
static void render_status(void) {
    oled_write_ln_P(PSTR("CORNE R2G"), false);
    oled_write_P(PSTR("Layer: "), false);
    switch (get_highest_layer(layer_state | default_layer_state)) {
        case _BASE:
            oled_write_ln_P(PSTR("BASE"), false);
            break;
        case _FN:
            oled_write_ln_P(PSTR("FN"), false);
            break;
        default:
            oled_write_ln_P(PSTR("?"), false);
            break;
    }

    led_t led_state = host_keyboard_led_state();
    oled_write_P(PSTR("Caps:  "), false);
    oled_write_ln_P(led_state.caps_lock ? PSTR("ON") : PSTR("off"), false);
}

static void render_fn_legend(void) {
    if (get_highest_layer(layer_state | default_layer_state) == _FN) {
        oled_write_ln_P(PSTR("@789*  ^{}[]"), false);
        oled_write_ln_P(PSTR("&456+  <v^>~"), false);
        oled_write_ln_P(PSTR("=123$  ()<>\\"), false);
        oled_write_ln_P(PSTR("edge=RGB/boot"), false);
    } else {
        oled_write_ln_P(PSTR("Hold FN"), false);
        oled_write_ln_P(PSTR("for symbol map"), false);
        oled_write_ln_P(PSTR("thumbs fixed"), false);
        oled_write_ln_P(PSTR("S W B E SPC"), false);
    }
}

oled_rotation_t oled_init_user(oled_rotation_t rotation) {
    if (!is_keyboard_master()) {
        return OLED_ROTATION_180;
    }
    return rotation;
}

bool oled_task_user(void) {
    oled_clear();
    oled_set_cursor(0, 0);
    if (is_keyboard_master()) {
        render_status();
    } else {
        render_fn_legend();
    }
    return false;
}
#endif

const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {
    [_BASE] = LAYOUT_split_3x6_3(
        KC_ESC,  KC_Q,    KC_W,    KC_E,    KC_R,    KC_T,                         KC_Y,    KC_U,    KC_I,    KC_O,    KC_P,    KC_MINUS,
        KC_TAB,  KC_A,    KC_S,    KC_D,    KC_F,    KC_G,                         KC_H,    KC_J,    KC_K,    KC_L,    KC_SCLN, KC_PLUS,
        KC_LCTL, KC_Z,    KC_X,    KC_C,    KC_V,    KC_B,                         KC_N,    KC_M,    KC_COMM, KC_DOT,  KC_SLSH, KC_BSLS,
                                   KC_LSFT, KC_LGUI, KC_BSPC,                      KC_ENT,  KC_SPC,  MO(_FN)
    ),

    [_FN] = LAYOUT_split_3x6_3(
        QK_BOOT, KC_AT,   KC_7,    KC_8,    KC_9,    KC_ASTR,                      KC_CIRC, KC_LCBR, KC_RCBR, KC_LBRC, KC_RBRC, UG_HUEU,
        UG_TOGG, KC_AMPR, KC_4,    KC_5,    KC_6,    KC_QUOT,                      KC_LEFT, KC_DOWN, KC_UP,   KC_RGHT, KC_TILD, UG_VALU,
        UG_NEXT, KC_EQL,  KC_1,    KC_2,    KC_3,    KC_BSLS,                      KC_DLR,  KC_LPRN, KC_RPRN, KC_LT,   KC_GRV,   UG_VALD,
                                   KC_LSFT, KC_LGUI, KC_BSPC,                      KC_ENT,  KC_SPC,  MO(_FN)
    )
};
