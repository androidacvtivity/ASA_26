$(document).ready(function () {
    form = $("#formDenShort").val();
    fASA_CAP9();
});

$(function () {
    // OnKeyPress ```````````````````````````````````````````````````````````````````````````````
    $("input:not([type='button']):not([readonly]):not([disabled])").on("change", function (e) {
        fASA_CAP9();
    });
});

function fASA_CAP9() {

    var R900_1 = $("#64_1214_111931_900_1");
    var R910_1 = $("#64_1214_111932_910_1");
    var R920_1 = $("#64_1214_111933_920_1");
    var R930_1 = $("#64_1214_111934_930_1");
    var R940_1 = $("#64_1214_111935_940_1");
    var R950_1 = $("#64_1214_111936_950_1");
    var R960_1 = $("#64_1214_111937_960_1");


    //-------------- readOnly inputs -----------------------
    R900_1.prop("readonly", true);
    R910_1.prop("readonly", true);
    R950_1.prop("readonly", true);

    // citește float (acceptă și virgula), 2 zecimale
    function NVAL($el) {
        var v = ($el.val() || "").toString().trim()
            .replace(/\s/g, "")
            .replace(",", ".");
        var n = parseFloat(v);
        return isNaN(n) ? 0 : n;
    }

    // dacă e 0 sau NaN -> gol, altfel afișează cu 2 zecimale
    function SETVAL($el, v) {
        if (!v || isNaN(v)) $el.val("");
        else $el.val(Number(v).toFixed(2));
    }

    // Rd.910 = Rd.920 + Rd.930
    var total910 = NVAL(R920_1) + NVAL(R930_1);
    SETVAL(R910_1, total910);

    // Rd.950 = Rd.920 + Rd.940
    var total950 = NVAL(R920_1) + NVAL(R940_1);
    SETVAL(R950_1, total950);

    // Rd.900 = Rd.910 + Rd.920 + Rd.930 + Rd.940 + Rd.950 + Rd.960 + Rd.970
    var total900 =
        NVAL(R910_1) +
        //  NVAL(R920_1) +
        //  NVAL(R930_1) +
        //  NVAL(R940_1) +
        //  NVAL(R950_1) +
        NVAL(R960_1)
        //NVAL(R970_1)
        ;

    SETVAL(R900_1, total900);
}
