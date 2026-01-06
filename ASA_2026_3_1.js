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

webform.validators.asa23 = function (v, allowOverpass) {
    var values = Drupal.settings.mywebform.values,
        cfoj = values.TITLU_R1_C31,
        cfojNr = cfoj.substring(0, 3),
        cfp = values.TITLU_R5_C31,
        cfpNr = cfp.substring(0, 2);

    var cap1_r100 = new Decimal(values.CAP1_R100_C1 || 0),
        cap1_r110 = new Decimal(values.CAP1_R110_C1 || 0),
        cap1_r120 = new Decimal(values.CAP1_R120_C1 || 0),
        cap1_r130 = new Decimal(values.CAP1_R130_C1 || 0),
        cap1_r140 = new Decimal(values.CAP1_R140_C1 || 0),
        cap1_r150 = new Decimal(values.CAP1_R150_C1 || 0);







    if (cfpNr == '12' && !(cfojNr == '500' || cfojNr == '510' || cfojNr == '520' || cfojNr == '530' || cfojNr == '590' || cfojNr == '690' || cfojNr == '880' || cfojNr == '960')) {
        webform.errors.push({
            'fieldName': 'TITLU_R1_C31',
            'msg': Drupal.t('Cod eroare: A.01, Daca CFP = 12, atunci CFOJ = 500, 510, 520, 530, 590, 690, 880, 960')
        });
    }

    if (cfpNr == '13' && !(cfojNr == '500' || cfojNr == '510' || cfojNr == '520' || cfojNr == '530' || cfojNr == '620' || cfojNr == '690' || cfojNr == '880' || cfojNr == '960')) {
        webform.errors.push({
            'fieldName': 'TITLU_R1_C31',
            'msg': Drupal.t('Cod eroare: A.02, Daca CFP = 13. atunci CFOJ = 500, 510, 520, 530, 620, 690, 880, 960')
        });
    }

    if ((cfpNr == '15' || cfpNr == '16' || cfpNr == '18') &&
        !(cfojNr == '420' || cfojNr == '430' || cfojNr == '440' || cfojNr == '450' || cfojNr == '500' || cfojNr == '510' || cfojNr == '520' || cfojNr == '530' || cfojNr == '540' ||
            cfojNr == '541' || cfojNr == '550' || cfojNr == '560' || cfojNr == '690' || cfojNr == '700' || cfojNr == '871' || cfojNr == '890' || cfojNr == '899' || cfojNr == '900' ||
            cfojNr == '910' || cfojNr == '930' || cfojNr == '940' || cfojNr == '950' || cfojNr == '960' || cfojNr == '970' || cfojNr == '980' || cfojNr == '990' || cfojNr == '992' ||
            cfojNr == '993' || cfojNr == '994' || cfojNr == '995' || cfojNr == '998')) {
        webform.errors.push({
            'fieldName': 'TITLU_R1_C31',
            'msg': Drupal.t('Cod eroare: A.03, Daca CFP = 15, 16, 18, atunci CFOJ = 420, 430, 440, 450, 500, 510, 520, 530, 540, 541, 550, 560, 690, 700, 871, 890, 899, 900, 910, 930, 940, 950, 960, 970, 980, 990, 992, 993, 994, 995, 998')
        });
    }

    if (cfpNr == '20' && !(cfojNr == '500' || cfojNr == '510' || cfojNr == '520' || cfojNr == '530' || cfojNr == '690')) {
        webform.errors.push({
            'fieldName': 'TITLU_R1_C31',
            'msg': Drupal.t('Cod eroare: A.04, Daca CFP = 20, atunci CFOJ = 500, 510, 520, 530, 690')
        });
    }

    if (
        cfpNr == '28' && !(cfojNr == '430' || cfojNr == '440' || cfojNr == '500' || cfojNr == '510' || cfojNr == '520' || cfojNr == '530' || cfojNr == '540' || cfojNr == '550' ||
            cfojNr == '560' || cfojNr == '690' || cfojNr == '920' || cfojNr == '950' || cfojNr == '960')) {
        webform.errors.push({
            'fieldName': 'TITLU_R1_C31',
            'msg': Drupal.t('Cod eroare: A.05, Daca CFP = 28, atunci CFOJ = 430, 440, 500, 510, 520, 530, 540, 550, 560, 690, 920, 950, 960')
        });
    }

    if ((cfpNr == '23' || cfpNr == '24' || cfpNr == '25' || cfpNr == '26') && !(cfojNr == '500' || cfojNr == '510' || cfojNr == '520' || cfojNr == '530' || cfojNr == '540' ||
        cfojNr == '550' || cfojNr == '560' || cfojNr == '690' || cfojNr == '871' || cfojNr == '890' || cfojNr == '899' || cfojNr == '910' || cfojNr == '920' || cfojNr == '940' ||
        cfojNr == '950' || cfojNr == '960' || cfojNr == '996' || cfojNr == '997')) {
        webform.errors.push({
            'fieldName': 'TITLU_R1_C31',
            'msg': Drupal.t('Cod eroare: A.06, Daca CFP = 23, 24, 25, 26, atunci CFOJ = 500, 510, 520, 530, 540, 550, 560, 690, 871, 890, 899, 910, 920, 940, 950, 960, 996, 997')
        });
    }


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


        //Cum in JS in Drupal sa  scriu in IF aceasta conditie  (daca este mai mare sau mai mic de 4 carectere )
        var caem = 0;
        caem = values.CAP4_R_C31[i];
        var caem_c = 0;
        caem_c = values.CAP4_R_C32[i];

        if ((caem.length !== 4 || !/^\d+$/.test(caem)) && (values.CHESTIONAR_RA_C1 == true)) {
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


        if (code_code === false && (values.CHESTIONAR_RA_C1 == true)) {
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

        if (caem805Nr4 == '' && (values.CHESTIONAR_RA_C1 == true)) {
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
    //Show all variable
    // if (!Decimal(values.CAP4_R400_C3 || 0).equals(values.CAP1_R150_C1 || 0)) {
    //     webform.errors.push({
    //         'fieldName': 'CAP4_R400_C3',
    //         'msg': Drupal.t('Cod eroare: 64-007, [r.400 c.1] = [r.150 c.1]')
    //     });
    // }



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


    //This is code in JS for Drupal
    // var countCap1SpecificRows = 0;
    // var cap1SpecificFields = ['CAP1_R100_C1', 'CAP1_R110_C1', 'CAP1_R120_C1', 'CAP1_R130_C1', 'CAP1_R140_C1'];
    // for (var fi = 0; fi < cap1SpecificFields.length; fi++) {
    //     if (values[cap1SpecificFields[fi]]) {

    //         countCap1SpecificRows++;
    //     }
    // }



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

    if (emptyFields && (values.CHESTIONAR_RA_C1 == true)) {
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
