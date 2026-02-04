(function ($) {
    var activity_options_default_value = '';
    Drupal.behaviors.asa23 = {
        attach: function (context, settings) {
            if (!Drupal.settings.mywebform.preview) {
                activity_options_default_value = (typeof Drupal.settings.mywebform.values.CAEM != "undefined" ? Drupal.settings.mywebform.values.CAEM : '');
            }

            jQuery('#mywebform-edit-form').on('keypress', 'input.money, input.float, input.numeric', function (event) {
                if (isNumberPressed(this, event) === false) {
                    event.preventDefault();
                }
            });


        }
    };

   
    
})(jQuery);
webform.afterLoad.asa23 = function () {
    if (!Drupal.settings.mywebform.preview) {
        var villages = jQuery("select[field='CAP5_R_C36']").myWebformSelect2GetOptions();
        villages.forEach(function (village, index) {
            if (village.id == '0000000') {
                villages.splice(index, 1);
                return;
            }
        });


        var arrayCaem = ['CAP4_R_C32', 'CAP5_R_C37'];

        //Sa face, altfel ce face acest cod - dupa acest exemplu trebuie de facut 
        jQuery.each(arrayCaem, function (key, value) {
            set_caem_to_select(value, null, null);
            set_options_html(value);
        });
    }
};

function set_options_html(selector) {
    var caemValues = Drupal.settings.mywebform.values[selector];
    if (!jQuery.isEmptyObject(caemValues)) {
        jQuery.each(caemValues, function (key, value) {
            set_caem_to_select(selector, value, key + 1);
        });
    }
}

function set_caem_to_select(selector, valueCaem, keyCaem) {
    var obj = (keyCaem !== null ? jQuery('#' + selector + '-' + keyCaem) : jQuery('#' + selector));
    obj.empty();
    obj.append(jQuery("<option></option>").attr("value", '').text(''));
    jQuery.each(caem_select, function (key, value) {
        if (value.description == valueCaem)
            obj.append(
                jQuery("<option></option>").attr("value", value.description).attr("selected", "selected").text(value.description + " , " + value.name));
        else
            obj.append(
                jQuery("<option></option>").attr("value", value.description).text(value.description + " , " + value.name));
    });

    obj.change();
}



//---------------- Validari ASA 23 -----

// 64-103 (ERROR)
// CAP 2.1: r.2100 c.1 = CAP 2: r.220 c.1 + r.240 c.2  (valori float cu 1 zecimală)
function validate64_103(values) {

    // Stânga: Cap.2.1 r.2100 c.1
    var left = Decimal(values.CAP21_R2100_1_C1 || 0).toDecimalPlaces(1);

    // Dreapta: Cap.2 r.220 c.1
    var r220 = Decimal(values.CAP2_R220_C1 || 0).toDecimalPlaces(1);

    // Cap.2 r.240 c.2  (fallback: dacă nu există C2 în values, luăm C1 ca să nu crape)
    var r240_raw = (typeof values.CAP2_R240_C2 !== "undefined")
        ? values.CAP2_R240_C2
        : values.CAP2_R240_C1;

    var r240 = Decimal(r240_raw || 0).toDecimalPlaces(1);

    var right = r220.plus(r240).toDecimalPlaces(1);

    if (!left.equals(right)) {
        webform.errors.push({
            fieldName: 'CAP21_R2100_1_C1',
            msg: Drupal.t(
                'Cod eroare: 64-103, CAP 2.1 [r.2100 c.1 = @left] = CAP 2 [r.220 c.1 = @r220] + [r.240 c.2 = @r240]  => @right',
                {
                    '@left': left.toFixed(1),
                    '@r220': r220.toFixed(1),
                    '@r240': r240.toFixed(1),
                    '@right': right.toFixed(1)
                }
            )
        });
    }
}


//--- Validari ASA 23 -----

function validate_CFP_vs_Cfoj_ASA23(values) {
    // CFOJ = TITLU_R1_C31 (primele 3 cifre)
    // CFP  = TITLU_R5_C31 (primele 2 cifre)
    var cfoj = (values.TITLU_R1_C31 || "").toString();
    var cfp = (values.TITLU_R5_C31 || "").toString();

    var cfojNr = cfoj.substring(0, 3);
    var cfpNr = cfp.substring(0, 2);

    // reguli (exact cum ai cerut)
    var rules = [
        {
            cfp: ['12'],
            allowed: ['500', '510', '520', '590', '690'],
            errCode: 'A.02',
            msg: 'Daca CFP = 12, atunci CFOJ = 500, 510, 520, 590, 690'
        },
        {
            cfp: ['13'],
            allowed: ['500', '510', '520', '620', '690'],
            errCode: 'A.02',
            msg: 'Daca CFP = 13, atunci CFOJ = 500, 510, 520, 620, 690'
        },
        {
            cfp: ['15', '16', '18'],
            allowed: ['420', '430', '440', '450', '500', '510', '520', '530', '540', '541', '550', '560', '690', '993'],
            errCode: 'A.03',
            msg: 'Daca CFP = 15, 16, 18, atunci CFOJ = 420, 430, 440, 450, 500, 510, 520, 530, 540, 541, 550, 560, 690, 993'
        },
        {
            cfp: ['20'],
            allowed: ['500', '510', '520', '530', '690'],
            errCode: 'A.04',
            msg: 'Daca CFP = 20, atunci CFOJ = 500, 510, 520, 530, 690'
        },
        {
            cfp: ['28'],
            allowed: ['430', '440', '500', '510', '520', '530', '540', '550', '560', '690'],
            errCode: 'A.05',
            msg: 'Daca CFP = 28, atunci CFOJ = 430, 440, 500, 510, 520, 530, 540, 550, 560, 690'
        },
        {
            cfp: ['23', '24', '25', '26'],
            allowed: ['500', '510', '520', '530', '540', '550', '560', '690', '996'],
            errCode: 'A.06',
            msg: 'Daca CFP = 23, 24, 25, 26, atunci CFOJ = 500, 510, 520, 530, 540, 550, 560, 690, 996'
        }
    ];

    for (var i = 0; i < rules.length; i++) {
        var r = rules[i];

        if (r.cfp.indexOf(cfpNr) !== -1) {
            if (r.allowed.indexOf(cfojNr) === -1) {
                webform.errors.push({
                    fieldName: 'TITLU_R1_C31',
                    msg: Drupal.t('Cod eroare: ' + r.errCode + ', ' + r.msg)
                });
            }
            break; // o singură regulă se aplică
        }
    }
}

//--- Validari ASA 23 -----

// 64-102 (ERROR)
// CAP 2.1: pentru fiecare rând -> col.1 ≥ col.2 + col.3 + col.4
// (float cu 1 zecimală)
function validate64_102(values) {

    // colectăm dinamic toate câmpurile CAP21_Rxxxx_[1..4]_C1
    var rows = {}; // { "2101": {1:Decimal,2:Decimal,3:Decimal,4:Decimal}, ... }

    Object.keys(values || {}).forEach(function (k) {
        var m = /^CAP21_R(\d+)_(\d)_C1$/.exec(k);
        if (!m) return;

        var r = m[1];
        var c = parseInt(m[2], 10); // 1..4

        if (c < 1 || c > 4) return;

        if (!rows[r]) rows[r] = {};

        // rotunjim la 1 zecimală
        rows[r][c] = Decimal(values[k] || 0).toDecimalPlaces(1);
    });

    Object.keys(rows).forEach(function (r) {
        var col1 = (rows[r][1] !== undefined) ? rows[r][1] : Decimal(0).toDecimalPlaces(1);
        var col2 = (rows[r][2] !== undefined) ? rows[r][2] : Decimal(0).toDecimalPlaces(1);
        var col3 = (rows[r][3] !== undefined) ? rows[r][3] : Decimal(0).toDecimalPlaces(1);
        var col4 = (rows[r][4] !== undefined) ? rows[r][4] : Decimal(0).toDecimalPlaces(1);

        var sum234 = col2.plus(col3).plus(col4).toDecimalPlaces(1);

        // col.1 >= (col.2+col.3+col.4)  => eroare dacă col1 < sum234
        if (col1.lessThan(sum234)) {
            webform.errors.push({
                fieldName: 'CAP21_R' + r + '_1_C1',
                msg: Drupal.t(
                    'Cod eroare: 64-102, CAP 2.1 (r.@r) col.1 (@c1) < col.2+col.3+col.4 (@sum)',
                    {
                        '@r': r,
                        '@c1': col1.toFixed(1),
                        '@sum': sum234.toFixed(1)
                    }
                )
            });
        }
    });
}

//--- Validari ASA 23 -----
// 64-111 (ERROR)
// ASA - CAP.1: Dacă este completat r.111 (col.1 > 0),
// atunci în CAP.4 trebuie să existe cel puțin un CAEM-2 din lista exactă (COL3).
function validate64_111(values) {

    function toNum(v) {
        if (v === null || v === undefined) return 0;
        var s = String(v).trim().replace(/\s+/g, '').replace(',', '.');
        var n = parseFloat(s);
        return isNaN(n) ? 0 : n;
    }

    // Condiția: CAP.1 r.111 col.1 completat
    var r111 = toNum(values.CAP1_R111_C1);
    if (r111 <= 0) return;

    // Lista exactă (COL3)
    var allowed = [
        '3514', '3523', '4511', '4519', '4532', '4540',
        '4711', '4719', '4721', '4722', '4723', '4724', '4725', '4726', '4729',
        '4730', '4741', '4742', '4743',
        '4751', '4752', '4753', '4754', '4759',
        '4761', '4762', '4763', '4764', '4765',
        '4771', '4772', '4773', '4774', '4775', '4776', '4777', '4778', '4779',
        '4781', '4782', '4789', '4791', '4799'
    ];

    // Set pentru căutare rapidă
    var allowedSet = {};
    for (var i = 0; i < allowed.length; i++) allowedSet[allowed[i]] = true;

    // CAP4: luăm CAEM din C32 (select) sau C31 (input) – cum ai în formular
    var arr = [];
    if (values.CAP4_R_C32 && values.CAP4_R_C32.length) arr = values.CAP4_R_C32;
    else if (values.CAP4_R_C31 && values.CAP4_R_C31.length) arr = values.CAP4_R_C31;

    // normalizează: din "G4711" / "D3514" / "4711" => "4711" / "3514"
    function normalizeCaem(v) {
        var s = String(v || '').trim();
        // dacă vine cu literă (G/D), păstrăm doar cifrele
        s = s.replace(/[^\d]/g, '');
        return s;
    }

    var found = false;
    for (var j = 0; j < arr.length; j++) {
        var code = normalizeCaem(arr[j]);
        if (code && allowedSet[code]) {
            found = true;
            break;
        }
    }

    if (!found) {
        webform.errors.push({
            fieldName: "CAP4_R_C31",
            msg: Drupal.t(
                "Cod eroare: 64-111, Dacă CAP.1 r.111 este completat, atunci în CAP.4 trebuie să existe un CAEM-2 din lista permisă (ex.: G451, 4532, 454, 47,3514,3523)."
            )
        });
    }
}


//--- Validari ASA 23 -----


// 64-112 (ERROR)
// ASA - CAP.1: Dacă este completat r.112 (col.1 > 0),
// atunci în CAP.4 trebuie să existe cel puțin un CAEM-2 din lista permisă.
function validate64_112(values) {

    function toNum(v) {
        if (v === null || v === undefined) return 0;
        var s = String(v).trim().replace(/\s+/g, '').replace(',', '.');
        var n = parseFloat(s);
        return isNaN(n) ? 0 : n;
    }

    // Condiția: CAP.1 r.112 col.1 completat
    var r112 = toNum(values.CAP1_R112_C1);
    if (r112 <= 0) return;

    // Lista exactă CAEM2 (coduri)
    var allowed = [
        '3514', '3523', '4511', '4519', '4531', '4540',
        '4621', '4622', '4623', '4624',
        '4631', '4632', '4633', '4634', '4635', '4636', '4637', '4638', '4639',
        '4641', '4642', '4643', '4644', '4645', '4646', '4647', '4648', '4649',
        '4651', '4652',
        '4661', '4662', '4663', '4664', '4665', '4666', '4669',
        '4671', '4672', '4673', '4674', '4675', '4676', '4677',
        '4690'
    ];

    // Set pentru verificare rapidă
    var allowedSet = {};
    for (var i = 0; i < allowed.length; i++) allowedSet[allowed[i]] = true;

    // CAP4: CAEM din C32 (select) sau C31 (input)
    var arr = [];
    if (values.CAP4_R_C32 && values.CAP4_R_C32.length) arr = values.CAP4_R_C32;
    else if (values.CAP4_R_C31 && values.CAP4_R_C31.length) arr = values.CAP4_R_C31;

    // normalizează: "G4621" / "D3514" / "4621" => "4621"
    function normalizeCaem(v) {
        return String(v || '').trim().replace(/[^\d]/g, '');
    }

    var found = false;
    for (var j = 0; j < arr.length; j++) {
        var code = normalizeCaem(arr[j]);
        if (code && allowedSet[code]) {
            found = true;
            break;
        }
    }

    if (!found) {
        webform.errors.push({
            fieldName: "CAP4_R_C31",
            msg: Drupal.t(
                "Cod eroare: 64-112, Dacă CAP.1 r.112 este completat, atunci în CAP.4 trebuie să existe un CAEM-2 permis (3514, 3523, 4511, 4519, 4531, 4540, 4621-4690)."
            )
        });
    }
}

//--- Main validator ASA 23 -----

// 64-113 (WARNING)
// CAP.2: r.297 col.1 <= 20% din r.210 col.1  (float cu 1 zecimală)
function validate64_113(values) {

    var r210 = Decimal(values.CAP2_R210_C1 || 0).toDecimalPlaces(1);
    var r297 = Decimal(values.CAP2_R297_C1 || 0).toDecimalPlaces(1);

    // prag = 20% din r.210
    var limit = r210.times(Decimal(0.2)).toDecimalPlaces(1);

    // Warning dacă r.297 depășește 20% din r.210
    if (r297.greaterThan(limit)) {
        webform.warnings.push({
            fieldName: 'CAP2_R297_C1',
            msg: Drupal.t(
                'Cod eroare: 64-113, CAP.2 r.297 (@r297) depășește 20% din r.210 (@limit) [r.210=@r210].',
                {
                    '@r297': r297.toFixed(1),
                    '@limit': limit.toFixed(1),
                    '@r210': r210.toFixed(1)
                }
            )
        });
    }
}

//--- Validari ASA 23 -----
// 64-114 (WARNING)
// Cap. I: r.150 + r.160 + r.170 – r.200 + r.330 (c2-c1) + r.340 (c2-c1) >= 0
// (float cu 1 zecimală)
function validate64_114(values) {

    // folosim Decimal ca în celelalte validări ale tale
    function D(v) {
        return Decimal(v || 0).toDecimalPlaces(1);
    }

    // CAP. I (1124) - r.150/160/170 col.1
    var r150 = D(values.CAP1_R150_C1);
    var r160 = D(values.CAP1_R160_C1);
    var r170 = D(values.CAP1_R170_C1);

    // CAP. I (1125) - r.200 col.1
    // (în unele formulare poate fi tot CAP1; dacă la tine e alt prefix, îl ajustăm)
    var r200 = D(values.CAP1_R200_C1);

    // CAP. I (1126) - r.330/340 (col.2 - col.1)
    var r330_c1 = D(values.CAP1_R330_C1);
    var r330_c2 = D(values.CAP1_R330_C2);
    var r340_c1 = D(values.CAP1_R340_C1);
    var r340_c2 = D(values.CAP1_R340_C2);

    var diff330 = r330_c2.minus(r330_c1).toDecimalPlaces(1);
    var diff340 = r340_c2.minus(r340_c1).toDecimalPlaces(1);

    // expresia finală
    var expr = r150.plus(r160).plus(r170)
        .minus(r200)
        .plus(diff330)
        .plus(diff340)
        .toDecimalPlaces(1);

    // WARNING dacă e < 0
    if (expr.lessThan(Decimal(0).toDecimalPlaces(1))) {
        webform.warnings.push({
            fieldName: 'CAP1_R150_C1',
            msg: Drupal.t(
                'Cod eroare: 64-114, (r150+r160+r170) - r200 + (r330(c2-c1)) + (r340(c2-c1)) = @expr < 0. Detalii: r150=@r150, r160=@r160, r170=@r170, r200=@r200, r330=@d330, r340=@d340',
                {
                    '@expr': expr.toFixed(1),
                    '@r150': r150.toFixed(1),
                    '@r160': r160.toFixed(1),
                    '@r170': r170.toFixed(1),
                    '@r200': r200.toFixed(1),
                    '@d330': diff330.toFixed(1),
                    '@d340': diff340.toFixed(1)
                }
            )
        });
    }
}


//---  validator ASA 23 -----


// 64-118 (ERROR)
// Dacă este completat CAP2_R200_C1 (Cap.2 r.200 col.1),
// atunci obligatoriu CAP1_R110_C1 (Cap.1 r.110 col.1) și invers.
function validate64_118(values) {

    function toNum(v) {
        if (v === null || v === undefined) return 0;
        var s = String(v).trim().replace(/\s+/g, '').replace(',', '.');
        var n = parseFloat(s);
        return isNaN(n) ? 0 : n;
    }

    var r200 = toNum(values.CAP2_R200_C1);
    var r110 = toNum(values.CAP1_R110_C1);

    // “completat” = diferit de 0
    var is200 = (r200 !== 0);
    var is110 = (r110 !== 0);

    // r.200 completat -> r.110 obligatoriu
    if (is200 && !is110) {
        webform.errors.push({
            fieldName: 'CAP1_R110_C1',
            msg: Drupal.t('Cod eroare: 64-118, Dacă este completat Cap.2 r.200 (col.1), atunci trebuie completat obligatoriu Cap.1 r.110 (col.1).')
        });
    }

    // r.110 completat -> r.200 obligatoriu
    if (is110 && !is200) {
        webform.errors.push({
            fieldName: 'CAP2_R200_C1',
            msg: Drupal.t('Cod eroare: 64-118, Dacă este completat Cap.1 r.110 (col.1), atunci trebuie completat obligatoriu Cap.2 r.200 (col.1).')
        });
    }
}

//----------------------------------------------------------
// 64-122 (ERROR)
// Rd.400 col.2 = rd.500 col.2 = rd.900  (număr mediu salariați/persoane)
function validate64_122(values) {

    function D(v) {
        // acceptă și valori cu virgulă
        var s = (v === null || v === undefined) ? '0' : String(v).trim();
        s = s.replace(/\s+/g, '').replace(',', '.');
        return Decimal(s || 0).toDecimalPlaces(1);
    }

    // CAP.4 rd.400 col.2 -> CAP4_R400_C4
    var r400_c2 = D(values.CAP4_R400_C4);

    // CAP.5 rd.500 col.2 -> CAP5_R500_C9
    var r500_c2 = D(values.CAP5_R500_C9);

    // CAP.9 rd.900 col.1 -> CAP9_R900_C1
    var r900 = D(values.CAP9_R900_C1);

    var ok = r400_c2.equals(r500_c2) && r400_c2.equals(r900);

    if (!ok) {
        var msg = Drupal.t(
            'Cod eroare: 64-122, Rd.400 col.2 (@r400) trebuie să fie egal cu rd.500 col.2 (@r500) și rd.900 (@r900).',
            {
                '@r400': r400_c2.toFixed(1),
                '@r500': r500_c2.toFixed(1),
                '@r900': r900.toFixed(1)
            }
        );

        // marcăm toate câmpurile implicate (ca să fie evident unde e diferența)
        if (!r400_c2.equals(r500_c2) || !r400_c2.equals(r900)) {
            webform.errors.push({ fieldName: 'CAP4_R400_C4', msg: msg });
        }
        if (!r500_c2.equals(r400_c2) || !r500_c2.equals(r900)) {
            webform.errors.push({ fieldName: 'CAP5_R500_C9', msg: msg });
        }
        if (!r900.equals(r400_c2) || !r900.equals(r500_c2)) {
            webform.errors.push({ fieldName: 'CAP9_R900_C1', msg: msg });
        }
    }
}

//----------------------------------------------------------
// 64-123 (WARNING)
// Dublarea codului CAEM-2 (rev.2) în CAP.IV (rânduri dinamice)
function validate64_123(values) {

    // CAP4: cod CAEM poate fi în C31 (input) sau în C32 (select) – depinde de implementarea formularului
    var arr = [];
    var fieldName = 'CAP4_R_C31';

    if (values.CAP4_R_C31 && values.CAP4_R_C31.length) {
        arr = values.CAP4_R_C31;
        fieldName = 'CAP4_R_C31';
    } else if (values.CAP4_R_C32 && values.CAP4_R_C32.length) {
        arr = values.CAP4_R_C32;
        fieldName = 'CAP4_R_C32';
    } else {
        return; // nu există rânduri dinamice / nu e completat
    }

    // Rândurile (Nr. rd.) pentru mesaj, dacă există
    var rows = (values.CAP4_R_CA && values.CAP4_R_CA.length) ? values.CAP4_R_CA : null;

    function normalizeCaem(v) {
        // acceptă: "47.11", "G4711", "4711" => "4711"
        var s = String(v || '').trim();
        s = s.replace(/[^\d]/g, '');
        return s;
    }

    var seen = {};   // code -> first index
    var dups = {};   // code -> [indexes]

    for (var i = 0; i < arr.length; i++) {
        var code = normalizeCaem(arr[i]);
        if (!code) continue;

        if (seen[code] === undefined) {
            seen[code] = i;
        } else {
            if (!dups[code]) dups[code] = [seen[code]];
            dups[code].push(i);
        }
    }

    // Pentru fiecare cod duplicat, afișăm un warning
    for (var code in dups) {
        if (!dups.hasOwnProperty(code)) continue;

        var idxs = dups[code];
        var rowList = [];

        for (var j = 0; j < idxs.length; j++) {
            var k = idxs[j];
            // dacă avem Nr. rd. din formular – îl folosim, altfel index+1
            rowList.push(rows ? rows[k] : (k + 1));
        }

        webform.warnings.push({
            fieldName: fieldName,
            msg: Drupal.t(
                'Cod eroare: 64-123, Dublarea codului CAEM-2 (@code) în CAP.IV la rândurile: @rows.',
                { '@code': code, '@rows': rowList.join(', ') }
            )
        });
    }
}




//--- Main validator ASA 23 -----


// 64-125 (ERROR)
// CAP.2.1: pentru fiecare rând 2101-2130, col.1 ≥ col.2 + col.3 + col.4
function validate64_125(values) {

    function D(v) {
        // acceptă și valori cu virgulă și spații
        var s = (v === null || v === undefined) ? '0' : String(v).trim();
        s = s.replace(/\s+/g, '').replace(',', '.');
        return Decimal(s || 0).toDecimalPlaces(1);
    }

    var rows = [];
    for (var r = 2101; r <= 2130; r++) {
        rows.push(String(r));
    }

    for (var i = 0; i < rows.length; i++) {
        var row = rows[i];

        var c1 = D(values['CAP21_R' + row + '_1_C1']);
        var c2 = D(values['CAP21_R' + row + '_2_C1']);
        var c3 = D(values['CAP21_R' + row + '_3_C1']);
        var c4 = D(values['CAP21_R' + row + '_4_C1']);

        var sum = c2.plus(c3).plus(c4).toDecimalPlaces(1);

        if (c1.lessThan(sum)) {
            webform.errors.push({
                fieldName: 'CAP21_R' + row + '_1_C1',
                msg: Drupal.t(
                    'Cod eroare: 64-125, CAP.2.1 r.@row: col.1 (@c1) < col.2+col.3+col.4 (@sum) [c2=@c2, c3=@c3, c4=@c4].',
                    {
                        '@row': row,
                        '@c1': c1.toFixed(1),
                        '@c2': c2.toFixed(1),
                        '@c3': c3.toFixed(1),
                        '@c4': c4.toFixed(1),
                        '@sum': sum.toFixed(1)
                    }
                )
            });
        }
    }
}//----------------------------------------------------------
// 64-126 (ERROR)
// CAP.9: Rd.900 = Rd.910 + Rd.960
function validate64_126(values) {

    function D(v) {
        var s = (v === null || v === undefined) ? '0' : String(v).trim();
        s = s.replace(/\s+/g, '').replace(',', '.');
        return Decimal(s || 0).toDecimalPlaces(1);
    }

    var r900 = D(values.CAP9_R900_C1);
    var r910 = D(values.CAP9_R910_C1);
    var r960 = D(values.CAP9_R960_C1);

    var sum = r910.plus(r960).toDecimalPlaces(1);

    if (!r900.equals(sum)) {
        var msg = Drupal.t(
            'Cod eroare: 64-126, CAP.9 rd.900 (@r900) trebuie să fie egal cu rd.910 (@r910) + rd.960 (@r960) = @sum.',
            {
                '@r900': r900.toFixed(1),
                '@r910': r910.toFixed(1),
                '@r960': r960.toFixed(1),
                '@sum': sum.toFixed(1)
            }
        );

        webform.errors.push({ fieldName: 'CAP9_R900_C1', msg: msg });
        webform.errors.push({ fieldName: 'CAP9_R910_C1', msg: msg });
        webform.errors.push({ fieldName: 'CAP9_R960_C1', msg: msg });
    }
}

//----------------------------------------------------------
// 64-127 (ERROR)
// CAP.9: Rd.910 = Rd.920 + Rd.930
function validate64_127(values) {

    function D(v) {
        var s = (v === null || v === undefined) ? '0' : String(v).trim();
        s = s.replace(/\s+/g, '').replace(',', '.');
        return Decimal(s || 0).toDecimalPlaces(1);
    }

    var r910 = D(values.CAP9_R910_C1);
    var r920 = D(values.CAP9_R920_C1);
    var r930 = D(values.CAP9_R930_C1);

    var sum = r920.plus(r930).toDecimalPlaces(1);

    if (!r910.equals(sum)) {
        var msg = Drupal.t(
            'Cod eroare: 64-127, CAP.9 rd.910 (@r910) trebuie să fie egal cu rd.920 (@r920) + rd.930 (@r930) = @sum.',
            {
                '@r910': r910.toFixed(1),
                '@r920': r920.toFixed(1),
                '@r930': r930.toFixed(1),
                '@sum': sum.toFixed(1)
            }
        );

        webform.errors.push({ fieldName: 'CAP9_R910_C1', msg: msg });
        webform.errors.push({ fieldName: 'CAP9_R920_C1', msg: msg });
        webform.errors.push({ fieldName: 'CAP9_R930_C1', msg: msg });
    }
}

//----------------------------------------------------------
// 64-128 (ERROR)
// CAP.9: Rd.950 = Rd.920 + Rd.940
function validate64_128(values) {

    function D(v) {
        var s = (v === null || v === undefined) ? '0' : String(v).trim();
        s = s.replace(/\s+/g, '').replace(',', '.');
        return Decimal(s || 0).toDecimalPlaces(1);
    }

    var r950 = D(values.CAP9_R950_C1);
    var r920 = D(values.CAP9_R920_C1);
    var r940 = D(values.CAP9_R940_C1);

    var sum = r920.plus(r940).toDecimalPlaces(1);

    if (!r950.equals(sum)) {
        var msg = Drupal.t(
            'Cod eroare: 64-128, CAP.9 rd.950 (@r950) trebuie să fie egal cu rd.920 (@r920) + rd.940 (@r940) = @sum.',
            {
                '@r950': r950.toFixed(1),
                '@r920': r920.toFixed(1),
                '@r940': r940.toFixed(1),
                '@sum': sum.toFixed(1)
            }
        );

        webform.errors.push({ fieldName: 'CAP9_R950_C1', msg: msg });
        webform.errors.push({ fieldName: 'CAP9_R920_C1', msg: msg });
        webform.errors.push({ fieldName: 'CAP9_R940_C1', msg: msg });
    }
}

//-------------------------------------
// 64-129 (ERROR)
// Dacă există cel puțin un rând completat în CAP.1 sau CAP.2,
// atunci CAP.9 rd.980 (Timpul utilizat pentru completarea formularului, minute) se completează obligatoriu.
function validate64_129(values) {

    function isMeaningful(v) {
        if (v === null || v === undefined) return false;
        // arrays (rânduri dinamice)
        if (Array.isArray(v)) {
            for (var i = 0; i < v.length; i++) {
                if (isMeaningful(v[i])) return true;
            }
            return false;
        }
        var s = String(v).trim();
        if (s === '') return false;

        // numeric?
        var num = parseFloat(s.replace(/\s+/g, '').replace(',', '.'));
        if (!isNaN(num)) {
            return num !== 0;
        }
        // non-numeric text (coduri etc.) – dacă e completat, îl considerăm ca “există date”
        return true;
    }

    // 1) verificăm dacă există cel puțin un câmp completat (≠0 / ≠gol) în CAP.1 sau CAP.2
    var hasData = false;
    for (var k in values) {
        if (!values.hasOwnProperty(k)) continue;
        if (k.indexOf('CAP1_') === 0 || k.indexOf('CAP2_') === 0) {
            if (isMeaningful(values[k])) {
                hasData = true;
                break;
            }
        }
    }

    if (!hasData) {
        return; // nu există date în CAP.1/CAP.2 => nu cerem rd.980
    }

    // 2) dacă există date, rd.980 e obligatoriu
    var t = values.CAP9_R980_C1;
    var ok = isMeaningful(t);

    // dacă e numeric, să fie și > 0 (minute)
    if (ok) {
        var n = parseFloat(String(t).trim().replace(/\s+/g, '').replace(',', '.'));
        if (!isNaN(n) && n <= 0) {
            ok = false;
        }
    }

    if (!ok) {
        webform.errors.push({
            fieldName: 'CAP9_R980_C1',
            msg: Drupal.t(
                'Cod eroare: 64-129. Dacă există cel puțin un rând completat în CAP.1 sau CAP.2, atunci CAP.9 rînd.980 (timpul utilizat pentru completarea formularului, minute) se completează obligatoriu.'
            )
        });
    }
}


//----------------------------------------------------------

//----------------------------------------------------------
// 64-130 (ERROR)
// CAP.9: Dacă este completat r.930, atunci obligatoriu r.940 și invers.
function validate64_130(values) {

    function isFilled(v) {
        if (v === null || v === undefined) return false;

        // pentru array (dacă vreodată devine dinamic)
        if (Array.isArray(v)) {
            for (var i = 0; i < v.length; i++) {
                if (isFilled(v[i])) return true;
            }
            return false;
        }

        var s = String(v).trim();
        if (s === '') return false;

        // dacă e numeric -> “completat” = diferit de 0
        var n = parseFloat(s.replace(/\s+/g, '').replace(',', '.'));
        if (!isNaN(n)) return n !== 0;

        // text nenumeric -> dacă e completat, îl considerăm completat
        return true;
    }

    var is930 = isFilled(values.CAP9_R930_C1);
    var is940 = isFilled(values.CAP9_R940_C1);

    if (is930 !== is940) {
        var msg = Drupal.t('Cod eroare: 64-130, CAP.9: Dacă este completat r.930, atunci r.940 se completează obligatoriu și invers.');

        // marcăm ambele câmpuri ca să fie clar unde e problema
        webform.errors.push({ fieldName: 'CAP9_R930_C1', msg: msg });
        webform.errors.push({ fieldName: 'CAP9_R940_C1', msg: msg });
    }
}

//--- Main validator ASA 23 -----

//-------------------------------------
// 64-131 (ERROR)
// CAP.9: Dacă este completat r.920 sau r.940, atunci r.970 se completează obligatoriu.
function validate64_131(values) {

    function isFilled(v) {
        if (v === null || v === undefined) return false;

        if (Array.isArray(v)) {
            for (var i = 0; i < v.length; i++) {
                if (isFilled(v[i])) return true;
            }
            return false;
        }

        var s = String(v).trim();
        if (s === '') return false;

        var n = parseFloat(s.replace(/\s+/g, '').replace(',', '.'));
        if (!isNaN(n)) return n !== 0;

        return true;
    }

    var is920 = isFilled(values.CAP9_R920_C1);
    var is940 = isFilled(values.CAP9_R940_C1);
    var is970 = isFilled(values.CAP9_R970_C1);

    if ((is920 || is940) && !is970) {
        var msg = Drupal.t('Cod eroare: 64-131, CAP.9: Dacă este completat r.920 sau r.940, atunci r.970 se completează obligatoriu.');

        webform.errors.push({ fieldName: 'CAP9_R970_C1', msg: msg });
        // marcăm și câmpurile declanșatoare ca să fie clar de unde vine condiția
        webform.errors.push({ fieldName: 'CAP9_R920_C1', msg: msg });
        webform.errors.push({ fieldName: 'CAP9_R940_C1', msg: msg });
    }
}


//--
webform.validators.asa23 = function (v, allowOverpass) {
    var values = Drupal.settings.mywebform.values,
        cfoj = values.TITLU_R1_C31,
        cfojNr = cfoj.substring(0, 3),
        cfp = values.TITLU_R5_C31,
        cfpNr = cfp.substring(0, 2);


    validate_CFP_vs_Cfoj_ASA23(values);
    validate64_103(values);
    validate64_102(values);
    validate64_111(values);
    validate64_112(values);
    validate64_113(values);
    validate64_114(values);
    validate64_118(values);
    validate64_122(values);
    validate64_123(values);
    validate64_125(values);
    validate64_126(values);
    validate64_127(values);
    validate64_128(values);
    validate64_129(values); 
    validate64_130(values);
    validate64_131(values)

    var cap1_r100 = new Decimal(values.CAP1_R100_C1 || 0),
        cap1_r110 = new Decimal(values.CAP1_R110_C1 || 0),
        cap1_r120 = new Decimal(values.CAP1_R120_C1 || 0),
        cap1_r130 = new Decimal(values.CAP1_R130_C1 || 0),
        cap1_r140 = new Decimal(values.CAP1_R140_C1 || 0),
        cap1_r150 = new Decimal(values.CAP1_R150_C1 || 0);






    

    //CAP.4 Col.3 pentru CAEM-2: 3514, 3523,  451, 453, 454, 462-469, 47  se completeaza obligatoriu

    //Start
    var caem = 0,
        caemNr4 = 0,
        caemNr3 = 0,
        caemNr2 = 0,

        caemNr4_c = 0,
        caemNr3_c = 0,
        caemNr2_c = 0,

        thirdCol = 0;
    var caem6Nr4Arr = ['3514', '3523'],
        caem6Nr3Arr = ['451', '453', '454', '462', '463', '464', '465', '466', '467', '468', '469'],
        caem6Nr2Arr = ['47'];

    caem6Nr2Arr_56 = ['56'];
    caem6Nr4Grupa = ['0000', '0100', '0110', '0120', '0140', '0160', '0200', '0300', '0310', '0320', '0500', '0600', '0700', '0720', '0800', '0810', '0890', '0900', '1000', '1010', '1030', '1040',
        '1050', '1060', '1070', '1080', '1090', '1100', '1300', '1390', '1400', '1410', '1430', '1500', '1510', '1600', '1620', '1700', '1710', '1720', '1800', '1810', '1900', '2000', '2010', '2040', '2050',
        '2100', '2200', '2210', '2220', '2300', '2310', '2330', '2340', '2350', '2360', '2390', '2400', '2430', '2440', '2450', '2500', '2510', '2520', '2560', '2570', '2590', '2600', '2610', '2650',
        '2700', '2710', '2730', '2750', '2800', '2810', '2820', '2840', '2890', '2900', '2930', '3000', '3010', '3090', '3100', '3200', '3210', '3290', '3300', '3310', '3500', '3510', '3520',
        '3800', '3810', '3820', '3830', '4100', '4200', '4210', '4220', '4290', '4300', '4310', '4320', '4330', '4390', '4500', '4510', '4530', '4600', '4610', '4620', '4630', '4640', '4650', '4660',
        '4670', '4700', '4710', '4720', '4740', '4750', '4760', '4770', '4780', '4790', '4900', '4930', '4940', '5000', '5100', '5120', '5200', '5220', '5300', '5500', '5600', '5620', '5800', '5810',
        '5820', '5900', '5910', '6000', '6100', '6200', '6300', '6310', '6390', '6400', '6410', '6490', '6500', '6510', '6600', '6610', '6620', '6800', '6830', '6900', '7000', '7020', '7100', '7110',
        '7200', '7210', '7300', '7310', '7400', '7700', '7710', '7720', '7730', '7800', '7900', '7910', '8000', '8100', '8120', '8200', '8210', '8290', '8400', '8410', '8420', '8500', '8530', '8540',
        '8550', '8600', '8620', '8700', '8800', '8890', '9000', '9100', '9300', '9310', '9320', '9400', '9410', '9490', '9500', '9510', '9520', '9600', '9800'];


    //------------------------
    caem4_codul = [
        '0111', '0112', '0113', '0114', '0115',
        '0116', '0119', '0121', '0122', '0123',
        '0124', '0125', '0126', '0127', '0128',
        '0129', '0130', '0141', '0142', '0143',
        '0144', '0145', '0146', '0147', '0149',
        '0150', '0161', '0162', '0163', '0164',
        '0170', '0210', '0220', '0230', '0240',
        '0311', '0312', '0321', '0322', '0510',
        '0520', '0610', '0620', '0710', '0721',
        '0729', '0811', '0812', '0891', '0892',
        '0893', '0899', '0910', '0990', '1011',
        '1012', '1013', '1020', '1031', '1032',
        '1039', '1041', '1042', '1051', '1052',
        '1061', '1062', '1071', '1072', '1073',
        '1081', '1082', '1083', '1084', '1085',
        '1086', '1089', '1091', '1092', '1101',
        '1102', '1103', '1104', '1105', '1106',
        '1107', '1200', '1310', '1320', '1330',
        '1391', '1392', '1393', '1394', '1395',
        '1396', '1399', '1411', '1412', '1413',
        '1414', '1419', '1420', '1431', '1439',
        '1511', '1512', '1520', '1610', '1621',
        '1622', '1623', '1624', '1629', '1711',
        '1712', '1721', '1722', '1723', '1724',
        '1729', '1811', '1812', '1813', '1814',
        '1820', '1910', '1920', '2011', '2012',
        '2013', '2014', '2015', '2016', '2017',
        '2020', '2030', '2041', '2042', '2051',
        '2052', '2053', '2059', '2060', '2110',
        '2120', '2211', '2219', '2221', '2222',
        '2223', '2229', '2311', '2312', '2313',
        '2314', '2319', '2320', '2331', '2332',
        '2341', '2342', '2343', '2344', '2349',
        '2351', '2352', '2361', '2362', '2363',
        '2364', '2365', '2369', '2370', '2391',
        '2399', '2410', '2420', '2431', '2432',
        '2433', '2434', '2441', '2442', '2443',
        '2444', '2445', '2446', '2451', '2452',
        '2453', '2454', '2511', '2512', '2521',
        '2529', '2530', '2540', '2550', '2561',
        '2562', '2571', '2572', '2573', '2591',
        '2592', '2593', '2594', '2599', '2611',
        '2612', '2620', '2630', '2640', '2651',
        '2652', '2660', '2670', '2680', '2711',
        '2712', '2720', '2731', '2732', '2733',
        '2740', '2751', '2752', '2790', '2811',
        '2812', '2813', '2814', '2815', '2821',
        '2822', '2823', '2824', '2825', '2829',
        '2830', '2841', '2849', '2891', '2892',
        '2893', '2894', '2895', '2896', '2899',
        '2910', '2920', '2931', '2932', '3011',
        '3012', '3020', '3030', '3040', '3091',
        '3092', '3099', '3101', '3102', '3103',
        '3109', '3211', '3212', '3213', '3220',
        '3230', '3240', '3250', '3291', '3299',
        '3311', '3312', '3313', '3314', '3315',
        '3316', '3317', '3319', '3320', '3511',
        '3512', '3513', '3514', '3521', '3522',
        '3523', '3530', '3600', '3700', '3811',
        '3812', '3821', '3822', '3831', '3832',
        '3900', '4110', '4120', '4211', '4212',
        '4213', '4221', '4222', '4291', '4299',
        '4311', '4312', '4313', '4321', '4322',
        '4329', '4331', '4332', '4333', '4334',
        '4339', '4391', '4399', '4511', '4519',
        '4520', '4531', '4532', '4540', '4611',
        '4612', '4613', '4614', '4615', '4616',
        '4617', '4618', '4619', '4621', '4622',
        '4623', '4624', '4631', '4632', '4633',
        '4634', '4635', '4636', '4637', '4638',
        '4639', '4641', '4642', '4643', '4644',
        '4645', '4646', '4647', '4648', '4649',
        '4651', '4652', '4661', '4662', '4663',
        '4664', '4665', '4666', '4669', '4671',
        '4672', '4673', '4674', '4675', '4676',
        '4677', '4690', '4711', '4719', '4721',
        '4722', '4723', '4724', '4725', '4726',
        '4729', '4730', '4741', '4742', '4743',
        '4751', '4752', '4753', '4754', '4759',
        '4761', '4762', '4763', '4764', '4765',
        '4771', '4772', '4773', '4774', '4775',
        '4776', '4777', '4778', '4779', '4781',
        '4782', '4789', '4791', '4799', '4910',
        '4920', '4931', '4932', '4939', '4941',
        '4942', '4950', '5010', '5020', '5030',
        '5040', '5110', '5121', '5122', '5210',
        '5221', '5222', '5223', '5224', '5229',
        '5310', '5320', '5510', '5520', '5530',
        '5590', '5610', '5621', '5629', '5630',
        '5811', '5812', '5813', '5814', '5819',
        '5821', '5829', '5911', '5912', '5913',
        '5914', '5920', '6010', '6020', '6110',
        '6120', '6130', '6190', '6201', '6202',
        '6203', '6209', '6311', '6312', '6391',
        '6399', '6411', '6419', '6420', '6430',
        '6491', '6492', '6499', '6511', '6512',
        '6520', '6530', '6611', '6612', '6619',
        '6621', '6622', '6629', '6630', '6810',
        '6820', '6831', '6832', '6910', '6920',
        '7010', '7021', '7022', '7111', '7112',
        '7120', '7211', '7219', '7220', '7311',
        '7312', '7320', '7410', '7420', '7430',
        '7490', '7500', '7711', '7712', '7721',
        '7722', '7729', '7731', '7732', '7733',
        '7734', '7735', '7739', '7740', '7810',
        '7820', '7830', '7911', '7912', '7990',
        '8010', '8020', '8030', '8110', '8121',
        '8122', '8129', '8130', '8211', '8219',
        '8220', '8230', '8291', '8292', '8299',
        '8411', '8412', '8413', '8421', '8422',
        '8423', '8424', '8425', '8430', '8510',
        '8520', '8531', '8532', '8541', '8542',
        '8551', '8552', '8553', '8559', '8560',
        '8610', '8621', '8622', '8623', '8690',
        '8710', '8720', '8730', '8790', '8810',
        '8891', '8899', '9001', '9002', '9003',
        '9004', '9101', '9102', '9103', '9104',
        '9200', '9311', '9312', '9313', '9319',
        '9321', '9329', '9411', '9412', '9420',
        '9491', '9492', '9499', '9511', '9512',
        '9521', '9522', '9523', '9524', '9525',
        '9529', '9601', '9602', '9603', '9604',
        '9609', '9700', '9810', '9820', '9900'
    ];

    //------------------------

    caem4_codul_r = [
        '3514',
        '3523',
        '4511',
        '4519',
        '4531',
        '4532',
        '4540',
        '4621',
        '4622',
        '4623',
        '4624',
        '4631',
        '4632',
        '4633',
        '4634',
        '4635',
        '4636',
        '4637',
        '4638',
        '4639',
        '4641',
        '4642',
        '4643',
        '4644',
        '4645',
        '4646',
        '4647',
        '4648',
        '4649',
        '4651',
        '4652',
        '4661',
        '4662',
        '4663',
        '4664',
        '4665',
        '4666',
        '4669',
        '4671',
        '4672',
        '4673',
        '4674',
        '4675',
        '4676',
        '4677',
        '4690',
        '4711',
        '4719',
        '4721',
        '4722',
        '4723',
        '4724',
        '4725',
        '4726',
        '4729',
        '4730',
        '4741',
        '4742',
        '4743',
        '4751',
        '4752',
        '4753',
        '4754',
        '4759',
        '4761',
        '4762',
        '4763',
        '4764',
        '4765',
        '4771',
        '4772',
        '4773',
        '4774',
        '4775',
        '4776',
        '4777',
        '4778',
        '4779',
        '4781',
        '4782',
        '4789',
        '4791',
        '4799'
    ];







    for (i = 0; i < values.CAP4_R_C31.length; i++) {

        var codeMatch = false;
        var codeGroup = false;

        var code_code = false;


 
       var caem = 0;
        caem = values.CAP4_R_C31[i];
        var caem_c = 0;
        caem_c = values.CAP4_R_C32[i];

        if ((caem.length !== 4 || !/^\d+$/.test(caem))) {
            webform.errors.push({
                'fieldName': 'CAP4_R_C31',
                'index': i,
                'msg': Drupal.t('Cod eroare: 4.070, In cap.4 in coloana B [CAEM rev.2] codul caem2 trebuie sa contina 4 caractere si contina doar cifre')
            });
        }



        thirdCol = Number(values.CAP4_R_C5[i]);
        secondCol = Number(values.CAP4_R_C4[i]);
        firstCol = Number(values.CAP4_R_C3[i]);


        caemNr4 = caem.substring(0, 4);
        caemNr3 = caem.substring(0, 3);
        caemNr2 = caem.substring(0, 2);

        caemNr4_c = caem_c.substring(0, 4);
        caemNr3_c = caem_c.substring(0, 3);
        caemNr2_c = caem_c.substring(0, 2);


        if (caemNr4 != caemNr4_c) {
            webform.errors.push({
                'fieldName': 'CAP4_R_C32',
                'index': i,
                'msg': Drupal.t('Cod eroare: 4.012, In cap.4 in coloana B [CAEM rev.2]  trebuie  sa fie egala cu C')
            });
        }



        if (caemNr4 === 0) {
            webform.errors.push({
                'fieldName': 'CAP4_R_C31',
                'index': i,
                'msg': Drupal.t('Cod eroare: 4.010, In cap.4 in coloana B [CAEM rev.2] necesita obligatoriu o valoare')
            });
        }


        for (j = 0; j < caem4_codul.length; j++) {
            if (caemNr4 === caem4_codul[j]) {
                code_code = true;
            }
        }



        for (j = 0; j < caem6Nr4Grupa.length; j++) {
            if (caemNr4 === caem6Nr4Grupa[j]) {
                codeGroup = true;
            }
        }


        if (code_code === false ) {
            webform.errors.push({
                'fieldName': 'CAP4_R_C31',
                'index': i,
                'msg': Drupal.t('Cod eroare: 4.009, In cap.4 in coloana B [CAEM rev.2]  nu este introdus codul caem')
            });
        }


        if (codeGroup === true) {
            webform.errors.push({
                'fieldName': 'CAP4_R_C31',
                'index': i,
                'msg': Drupal.t('Cod eroare: 4.008, In cap.4 in coloana B [CAEM rev.2]  este introdus grupa')
            });
        }



        for (j = 0; j < caem6Nr4Arr.length; j++) {
            if (caemNr4 === caem6Nr4Arr[j]) {
                codeMatch = true;
            }
        }




        for (var k = 0; k < caem6Nr3Arr.length; k++) {
            if (caemNr3 === caem6Nr3Arr[k]) {
                codeMatch = true;
            }
        }

        for (var l = 0; l < caem6Nr2Arr.length; l++) {
            if (caemNr2 === caem6Nr2Arr[l]) {
                codeMatch = true;
            }
        }

        var codeMatch_56 = false;
        for (var l = 0; l < caem6Nr2Arr_56.length; l++) {
            if (caemNr2 === caem6Nr2Arr_56[l]) {
                codeMatch_56 = true;
            }
        }

        //caem6Nr2Arr_56

        if (codeMatch === true && thirdCol === 0) {
            webform.errors.push({
                'fieldName': 'CAP4_R_C5',
                'index': i,
                'msg': Drupal.t('Cod eroare: 64-107, CAP.4 Col.3 pentru CAEM-2: 3514, 3523,  451, 453, 454, 462-469, 47  se completeaza obligatoriu')
            });
        }

        if (codeMatch === false && thirdCol > 0 && caemNr2 != '56') {
            webform.errors.push({
                'fieldName': 'CAP4_R_C5',
                'index': i,
                'msg': Drupal.t('Cod eroare: 64-011, CAP.4 Col.3 se completeaza pentru CAEM-2: 3514, 3523, 3530, 451, 453, 454, 462-469, 47')
            });
        }
    }

    //End 






    var caem805 = 0;
    var caem805Nr4 = 0;

    for (var m = 0; m < values.CAP5_R_C37.length; m++) {
        caem805 = values.CAP5_R_C37[m];
        caem805Nr4 = Number(caem805.substring(0, 4));

        if (caem805Nr4 == '' ) {
            webform.errors.push({
                'fieldName': '3662',
                'index': m,
                'msg': Drupal.t('Cod eroare: 5.05, In cap.5 coloana F CAEM-2 necesita obligatoriu o valoare')
            });
        }
    }

    var caem6 = 0;
    var caem8 = 0;
    var matchFound = false;

    for (var i = 0; i < values.CAP4_R_C3.length; i++) {
        for (var j = 0; j < values.CAP5_R_C37.length; j++) {
            caem6 = values.CAP4_R_C31[i];
            caem8 = values.CAP5_R_C37[j];

            if (caem6 == caem8) {
                matchFound = true;
            }



            if (matchFound == false) {
                webform.errors.push({
                    'fieldName': 'CAP5_R_C37',
                    'index': j,
                    'msg': Drupal.t('Cod eroare: 5.09, In cap.5 in coloana F [CAEM rev.2] trebuie sa se reflecte cel putin un cod de activitate reflectat in cap.4 coloana B [CAEM rev.2]')
                });
            }
        }
    }





    //Start 64-037
    var sumR311_312 = Decimal(values.CAP2_R311_C1 || 0).plus(values.CAP2_R312_C1 || 0);
    var sumR310_037 = Decimal(values.CAP2_R310_C1 || 0);

    // Round the values to one sign after zero
    sumR311_312 = sumR311_312.toDecimalPlaces(1);
    sumR310_037 = sumR310_037.toDecimalPlaces(1);



    if (sumR310_037.lessThan(sumR311_312)) {
        var errorMsg = Drupal.t('Cod eroare: 64-037, Cap.2 [r.310 c.1] >= [r.311 c.1] + [r.312 c.1] - [r.310 c.1] < [r.311 c.1] + [r.312 c.1] = [sumR311_312] ', {
            '[sumR311_312]': sumR311_312.toFixed(1),
            '[r.310 c.1]': sumR310_037.toFixed(1),
            '[r.311 c.1]': Decimal(values.CAP2_R311_C1 || 0).toDecimalPlaces(1),
            '[r.312 c.1]': Decimal(values.CAP2_R312_C1 || 0).toDecimalPlaces(1),
            '[sumR311_312]': sumR311_312.toFixed(1)
        });
        webform.errors.push({
            'fieldName': 'CAP2_R310_C1',
            'msg': errorMsg
        });
    }
    //End 64-037


    //Start 64-038
    var cap3R330C1 = Decimal(values.CAP3_R330_C1 || 0);
    var cap3R340C1 = Decimal(values.CAP3_R340_C1 || 0);
    var cap3R350C1 = Decimal(values.CAP3_R350_C1 || 0);
    var cap3R320C1 = Decimal(values.CAP3_R320_C1 || 0);


    var sumR320 = cap3R330C1.plus(cap3R340C1).plus(cap3R350C1);
    sumR320 = sumR320.toDecimalPlaces(1);
    cap3R320C1 = cap3R320C1.toDecimalPlaces(1);

    if (cap3R320C1.lessThan(sumR320)) {
        webform.errors.push({
            'fieldName': 'CAP3_R320_C1',
            'msg': Drupal.t('Cod eroare: 64-038, Cap.3 [r.320 c.1 = @cap3R320C1] < [r.330 c.1 = @cap3R330C1] + [r.340 c.1 = @cap3R340C1] + [r.350 c.1 = @cap3R350C1],  [@sumR320]', { '@sumR320': sumR320.toFixed(1), '@cap3R320C1': cap3R320C1.toFixed(1), '@cap3R330C1': cap3R330C1.toFixed(1), '@cap3R340C1': cap3R340C1.toFixed(1), '@cap3R350C1': cap3R350C1.toFixed(1) })
        });
    }

    //End 64-038


    //Start 64-108
    var cap3R330C2 = Decimal(values.CAP3_R330_C2 || 0);
    var cap3R340C2 = Decimal(values.CAP3_R340_C2 || 0);
    var cap3R350C2 = Decimal(values.CAP3_R350_C2 || 0);
    var cap3R320C2 = Decimal(values.CAP3_R320_C2 || 0);


    var sumR320_C2 = cap3R330C2.plus(cap3R340C2).plus(cap3R350C2);
    sumR320_C2 = sumR320_C2.toDecimalPlaces(1);
    cap3R320C2 = cap3R320C2.toDecimalPlaces(1);

    if (cap3R320C2.lessThan(sumR320_C2)) {
        webform.errors.push({
            'fieldName': 'CAP3_R320_C2',
            'msg': Drupal.t('Cod eroare: 64-108, Cap.3 [r.320 c.2 = @cap3R320C2] < [r.330 c.2 = @cap3R330C2] + [r.340 c.2 = @cap3R340C2] + [r.350 c.2 = @cap3R350C2],  [@sumR320_C2]', { '@sumR320_C2': sumR320_C2.toFixed(1), '@cap3R320C2': cap3R320C2.toFixed(1), '@cap3R330C2': cap3R330C2.toFixed(1), '@cap3R340C2': cap3R340C2.toFixed(1), '@cap3R350C2': cap3R350C2.toFixed(1) })
        });
    }

    //End 64-108


    if (Decimal(values.CAP1_R111_C1 || 0).greaterThan(values.CAP1_R110_C1 || 0)) {
        webform.errors.push({
            'fieldName': 'CAP1_R111_C1',
            'msg': Drupal.t('Cod eroare: 3.08, [r.111 c.1] <= [r.110 c.1]')
        });
    }




    //--------------------------------------------------------------------------------


    if (!Decimal(values.CAP4_R400_C3 || 0).equals(values.CAP1_R150_C1 || 0)) {
        webform.errors.push({
            'fieldName': 'CAP4_R400_C3',
            'msg': Drupal.t('Cod eroare: 64-007, [r.400 c.1] = [r.150 c.1] unde  [r.400 c.1] = ' + Decimal(values.CAP4_R400_C3 || 0).toString() + ' <>  [r.150 c.1] = ' + Decimal(values.CAP1_R150_C1 || 0).toString())
        });
    }


    if (!Decimal(values.CAP4_R400_C4 || 0).equals(values.CAP5_R500_C9 || 0)) {
        webform.errors.push({
            'fieldName': 'CAP4_R400_C4',
            'msg': Drupal.t('Cod eroare: 64-009, [r.400 c.2] = [r.500 c.2]')
        });
    }

    if (!Decimal(values.CAP4_R400_C5 || 0).equals(values.CAP2_R200_C1 || 0)) {
        webform.errors.push({
            'fieldName': 'CAP4_R400_C5',
            'msg': Drupal.t('Cod eroare: 64-008, [r.400 c.3] = [r.200 c.1]')
        });
    }

    if (!Decimal(values.CAP5_R500_C8 || 0).equals(values.CAP1_R150_C1 || 0)) {
        webform.errors.push({
            'fieldName': 'CAP5_R500_C8',
            'msg': Drupal.t('Cod eroare: 64-013, [r.500 c.1] = [r.150 c.1]')
        });
    }

    if (!Decimal(values.CAP5_R500_C9 || 0).equals(values.CAP4_R400_C4 || 0)) {
        webform.errors.push({
            'fieldName': 'CAP5_R500_C9',
            'msg': Drupal.t('Cod eroare: 64-014, [r.500 c.2] = [r.400 c.2]')
        });
    }

    if (!Decimal(values.CAP5_R500_C10 || 0).equals(values.CAP2_R270_C1 || 0)) {
        webform.errors.push({
            'fieldName': 'CAP5_R500_C10',
            'msg': Drupal.t('Cod eroare: 64-017, [r.500 c.3] = [r.270 c.1]')
        });
    }



    //-------------------------------------------------------------------------------




    var rez1 = new Decimal(0),
        rez2 = new Decimal(0),
        rez3 = new Decimal(0),
        firstEntry = true;

    for (var i = 0; i < values.CAP5_R_C8.length; i++) {
        rez1 = rez1.plus(values.CAP5_R_C8[i] || 0);
        rez2 = rez2.plus(values.CAP5_R_C9[i] || 0);
        rez3 = rez3.plus(values.CAP5_R_C10[i] || 0);

        if (values.CAP5_R_C32[0] !== "SEDIUL CENTRAL" && firstEntry ) {
            firstEntry = false;
            webform.warnings.push({
                'fieldName': 'CAP5_R_C32',
                'index': i,
                'msg': Drupal.t('Cod eroare: 5.08, In cap.5 in coloana C pentru rind [510] trebuie sa introduceti "SEDIUL CENTRAL"')
            });
        }
    }

    var countCap4Rows = 0;
    var emptyFields = true;
    for (var i = 0; i < values.CAP4_R_C31.length; i++) {
        if (values.CAP4_R_C31[i]) {
            countCap4Rows++;
            if (values.CAP4_R_C31[i] != '' && i < 10) {
                emptyFields = false;
            }
        }
    }





    var countCap1SpecificRows = 0;
    var cap1SpecificFields = ['CAP1_R100_C1', 'CAP1_R110_C1', 'CAP1_R120_C1', 'CAP1_R130_C1', 'CAP1_R140_C1'];

    for (var fi = 0; fi < cap1SpecificFields.length; fi++) {
        var fieldValue = values[cap1SpecificFields[fi]];

        // Check if fieldValue is not "0.0" or ""
        if (fieldValue !== "0.0" && fieldValue !== "") {
            countCap1SpecificRows++;
        }
    }



    for (var i = 0; i < values.CAP4_R_C31.length; i++) {
        if (countCap4Rows < countCap1SpecificRows) {
            webform.errors.push({
                'fieldName': 'CAP4_R_C31',
                'index': i,
                'msg': ''
            });
        }
    }

    if (countCap4Rows < countCap1SpecificRows) {
        webform.errors.push({
            'fieldName': '',
            'msg': Drupal.t('Cod eroare: 1.05, Dacă sunt completate rd. 100, 110, 120, 130, 140, atunci pentru fiecare rând completat se atribuie măcar un cod CAEM în cap. 4')
        });
    }

    if (emptyFields ) {
        webform.errors.push({
            'fieldName': '',
            'msg': Drupal.t('Cod eroare: A.08, Dacă nu sunt completate rd.410-419 atunci - eroare critice')
        });
    }

    if (!values.TITLU_R3_C31) {
        webform.errors.push({
            'fieldName': 'TITLU_R3_C31',
            'msg': Drupal.t('Cod eroare: A.09, Dacă nu sunt completate în antet Nr tel.  atunci - eroare critice')
        });
    }

   // -------------------add  --
    // Check if the field is empty or has more than 9 digits
    if (!values.TITLU_R3_C31 || !/^[0-9]{9}$/.test(values.TITLU_R3_C31)) {
        webform.errors.push({
            'fieldName': 'TITLU_R3_C31',
            'msg': Drupal.t(' Cod eroare: A.09 Introduceți doar un număr de telefon format din 9 cifre')
        });
    }

    // Check if the first digit is 0
    if (values.TITLU_R3_C31 && values.TITLU_R3_C31[0] !== '0') {
        webform.errors.push({
            'fieldName': 'TITLU_R3_C31',
            'msg': Drupal.t(' Cod eroare: A.09 Prima cifră a numărului de telefon trebuie să  fie 0')
        });
    }



    // End  64-045



    // Start 64-006
    var sumR291 = Decimal(values.CAP2_R2911_C1 || 0).plus(values.CAP2_R2912_C1 || 0);
    var cap2R291C1 = Decimal(values.CAP2_R291_C1 || 0);

    // Round the values to one sign after zero
    sumR291 = sumR291.toDecimalPlaces(1);
    cap2R291C1 = cap2R291C1.toDecimalPlaces(1);

    if (cap2R291C1.lessThan(sumR291)) {
        var errorMsg = Drupal.t('Cod eroare: 64-006, r.291 c.1 >= r.2911c.1 + r.2912 c.1 - [r.291 c.1] < [r.2911c.1] + [r.2912 c.1] = [sumR291]', {
            '[sumR291]': sumR291.toFixed(1),
            '[r.291 c.1]': cap2R291C1.toFixed(1),
            '[r.2911c.1]': Decimal(values.CAP2_R2911_C1 || 0).toDecimalPlaces(1),
            '[r.2912 c.1]': Decimal(values.CAP2_R2912_C1 || 0).toDecimalPlaces(1)
        });
        webform.errors.push({
            'fieldName': 'CAP2_R291_C1',
            'msg': errorMsg
        });
    }
    // End 64-006

    //End 64-049





    if (values.CAP4_R400_C4 == ""
        && (values.CHESTIONAR_RA_C1 == true)) {
        webform.errors.push({
            'fieldName': 'CAP4_R400_C4',
            'msg': Drupal.t('Cod eroare: A.01, Cap.4 [r.400 c.2] >= 0')
        });
    }






    // Start 64 - 104

    if (!isNaN(Number(values["CAP2_R291_C1"]))) {
        var col2 = Number(values["CAP2_R2931_C1"]);
    }



    if (!isNaN(Number(values["CAP2_R293_C1"]))) {
        var col1 = Number(values["CAP2_R293_C1"]);
    }

    var SUM_COL2_COL4 = col2
    var SUM_COL2_COL4_F = parseFloat(SUM_COL2_COL4.toFixed(1));

    if (col1 < SUM_COL2_COL4_F) {
        webform.errors.push({
            'fieldName': 'CAP2_R293_C1',
            'weight': 5,
            'msg': Drupal.t('Cod eroare: 64-104  CAP.2 [r.293 c.1] >= [r.2931c.1] - @col1 <   @SUM_COL2_COL4_F ', { "@col1": col1, "@SUM_COL2_COL4_F": SUM_COL2_COL4_F })
        });
    }

    // End   64 - 104 



   



    // Start 64 - 105

    // Calculate the total value 
    function calculateTotal64_105(values) {
        return Decimal(values.CAP2_R2961_C1 || 0)
            .plus(values.CAP2_R2962_C1 || 0);

    }

    // Check if CAP2_R296_C1 is less than the total value
    function check64_105(values, webform) {
        var total64_105 = calculateTotal64_105(values).toDecimalPlaces(1);
        var CAP2_R296_C1 = Decimal(values.CAP2_R296_C1 || 0);
        CAP2_R296_C1 = CAP2_R296_C1.toDecimalPlaces(1);

        if (CAP2_R296_C1.lessThan(total64_105)) {
            webform.errors.push({
                'fieldName': 'CAP2_R296_C1',
                'msg': Drupal.t('Cod eroare: 64-105  CAP.2 [r.296 c.1] >= [r.2961c.1] + [r.2962 c.1] -  @CAP2_R296_C1 <   @total64_105', { "@CAP2_R296_C1": values.CAP2_R296_C1, "@total64_105": total64_105.toFixed() })
            });
        }
    }

    // Call the checkCap2R240C1 function
    check64_105(values, webform);







    // End   64 - 105



    // Start  64-002

    if (Decimal(values.CAP1_R151_C1 || 0).greaterThan(values.CAP1_R150_C1 || 0)) {
        webform.errors.push({
            'fieldName': 'CAP1_R151_C1',
            'msg': Drupal.t('Cod eroare: 64-002, [r.151 c.1] <= [r.150 c.1] -  @CAP1_R151_C1 >   @CAP1_R150_C1', { "@CAP1_R151_C1": values.CAP1_R151_C1, "@CAP1_R150_C1": values.CAP1_R150_C1 })
        });
    }

    // End  64-002


    //Start 64-033
    {


        // Calculate the total value of CAP2_R221_C1 through CAP2_R243_C1
        function calculateTotalCap2R221ToR222C1(values) {
            return Decimal(values.CAP2_R221_C1 || 0)
                .plus(values.CAP2_R222_C1 || 0);

        }

        // Check if CAP2_R220_C1 is less than the total value of CAP2_R241_C1 through CAP2_R243_C1
        function checkCap2R220C1(values, webform) {
            var totalCap2R221ToR222C1 = calculateTotalCap2R221ToR222C1(values).toDecimalPlaces(1);

            var CAP2_R220_C1 = Decimal(values.CAP2_R220_C1 || 0).toDecimalPlaces(1);
            CAP2_R220_C1 = CAP2_R220_C1.toDecimalPlaces(1);


            if (CAP2_R220_C1.lessThan(totalCap2R221ToR222C1)) {
                webform.errors.push({
                    'fieldName': 'CAP2_R220_C1',
                    'msg': Drupal.t('Cod eroare: 64-033, [r.220 c.1] >= [r.221c.1] + [r.222 c.1] -  @CAP2_R220_C1 <   @totalCap2R221ToR222C1', { "@CAP2_R220_C1": values.CAP2_R220_C1, "@totalCap2R221ToR222C1": totalCap2R221ToR222C1.toFixed() })
                });
            }
        }

        // Call the checkCap2R240C1 function
        checkCap2R220C1(values, webform);



    }

    //End 64-033

    //Start 64-034

    // Calculate the total value of CAP2_R241_C1 through CAP2_R243_C1
    function calculateTotalCap2R241ToR243C1(values) {
        return Decimal(values.CAP2_R241_C1 || 0)
            .plus(values.CAP2_R242_C1 || 0)
            .plus(values.CAP2_R243_C1 || 0);
    }

    // Check if CAP2_R240_C1 is less than the total value of CAP2_R241_C1 through CAP2_R243_C1
    function checkCap2R240C1(values, webform) {
        var totalCap2R241ToR243C1 = calculateTotalCap2R241ToR243C1(values).toDecimalPlaces(1);

        var CAP2_R240_C1 = Decimal(values.CAP2_R240_C1 || 0).toDecimalPlaces(1);
        CAP2_R240_C1 = CAP2_R240_C1.toDecimalPlaces(1);

        if (CAP2_R240_C1.lessThan(totalCap2R241ToR243C1)) {
            webform.errors.push({
                'fieldName': 'CAP2_R240_C1',
                'msg': Drupal.t('Cod eroare: 64-034, [r.240 c.1] >= [r.241c.1] + [r.242 c.1] + [r.243 c.1] -  @CAP2_R240_C1 <   @totalCap2R241ToR243C1', { "@CAP2_R240_C1": values.CAP2_R240_C1, "@totalCap2R241ToR243C1": totalCap2R241ToR243C1.toFixed() })
            });
        }
    }

    // Call the checkCap2R240C1 function
    checkCap2R240C1(values, webform);


    //End 64-034






    webform.validatorsStatus.asa23 = 1;
    validateWebform();
};;



//----- 


// ============================================
// ADDON ASA23: CAP4_R_C31 <-> CAP4_R_C32 (CAEM2) + hint doar când NU există codul
// Mesajul apare doar la BLUR/CHANGE (nu la input)
// ============================================
(function ($) {

    var asa23_lock = false;

    function getKeyFromId(id, base) {
        var m = String(id || "").match(new RegExp("^" + base + "-(\\d+)$"));
        return m ? parseInt(m[1], 10) : null; // 1-based
    }

    function getObj(selector, keyCaem) {
        return (keyCaem !== null && keyCaem !== undefined)
            ? $("#" + selector + "-" + keyCaem)
            : $("#" + selector);
    }

    function normalizeCaem(raw) {
        var digits = $.trim(String(raw || "")).replace(/[^\d]/g, "");
        if (digits.length === 3) digits = "0" + digits;
        return (digits.length === 4) ? digits : "";
    }

    function ensureHint($inp) {
        if (!$inp || !$inp.length) return $();
        var $hint = $inp.nextAll("span.asa23-caem-hint").first();
        if (!$hint.length) {
            $hint = $("<span class='asa23-caem-hint' style='margin-left:8px; font-size:12px; color:#b26a00;'></span>");
            $inp.after($hint);
        }
        return $hint;
    }

    function clearHint($inp) {
        var $hint = ensureHint($inp);
        if ($hint.length) $hint.text("");
    }

    function showHintNotExists($inp) {
        var $hint = ensureHint($inp);
        if ($hint.length) $hint.text("Cod CAEM-2 nu există în clasificator.");
    }

    function optionExists($sel, code) {
        return $sel && $sel.length && $sel.find("option[value='" + code + "']").length > 0;
    }

    function syncC31toC32($inp) {
        if (asa23_lock) return;

        var key = getKeyFromId($inp.attr("id"), "CAP4_R_C31");
        var code = normalizeCaem($inp.val());

        asa23_lock = true;
        try {
            var $sel = getObj("CAP4_R_C32", key);
            if (!$sel.length) return;

            // dacă nu e 4 cifre: nu arătăm nimic (nici warning), doar curățăm mesajul
            if (!code) {
                clearHint($inp);
                return;
            }

            // normalizează vizual inputul (ex: 01-10 -> 0110)
            $inp.val(code);

            // umple + selectează după logica ta
            set_caem_to_select("CAP4_R_C32", code, key);

            // dacă nu s-a selectat => nu există codul
            if (!optionExists($sel, code) || $sel.val() !== code) {
                $sel.val("").change();
                showHintNotExists($inp);
            } else {
                clearHint($inp);
            }

        } finally {
            asa23_lock = false;
        }
    }

    function syncC32toC31($sel) {
        if (asa23_lock) return;

        var key = getKeyFromId($sel.attr("id"), "CAP4_R_C32");
        var code = normalizeCaem($sel.val());

        asa23_lock = true;
        try {
            var $inp = getObj("CAP4_R_C31", key);
            if (!$inp.length) return;

            $inp.val(code).change();
            clearHint($inp);
        } finally {
            asa23_lock = false;
        }
    }

    function bindHandlers() {
        var $form = $("#mywebform-edit-form");
        $form.off(".asa23_caem_addon");

        // C31 -> C32: doar la ieșire din câmp (blur) și change
        $form.on("blur.asa23_caem_addon change.asa23_caem_addon",
            "input[id^='CAP4_R_C31']",
            function () { syncC31toC32($(this)); }
        );

        // C32 -> C31
        $form.on("change.asa23_caem_addon",
            "select[id^='CAP4_R_C32']",
            function () { syncC32toC31($(this)); }
        );
    }

    var oldAfterLoad = webform.afterLoad.asa23;
    webform.afterLoad.asa23 = function () {
        if (typeof oldAfterLoad === "function") oldAfterLoad();
        bindHandlers();
    };

})(jQuery);
