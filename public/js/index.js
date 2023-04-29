"use strict";
function main(locals) {
    const COMBINING_CHARACTER_CODES = [
        768, 769, 770, 771, 772, 773, 774, 775, 776, 783, 792, 793, 794, 796, 797, 798, 799,
        800, 804, 805, 807, 808, 809, 810, 812, 815, 816, 818, 820, 825, 826, 827, 828, 829, 832, 833, 836
    ];

    new Vue({
        el: '#app',
        data: Object.assign({
            placeholder: 'Input here',
            decorated_message: '',
            name: '',
            chats: []
        }, locals),
        methods: {
            decorate: function (str, min, max) {
                let ret = '';
                str.split('').forEach(function (chr) {
                    let codes = [chr.charCodeAt(0)];
                    for (let i = 0, l = choice(range(min, max)); i < l; i++) {
                        codes[codes.length] = choice(COMBINING_CHARACTER_CODES);
                    }
                    ret += String.fromCharCode.apply(null, codes);
                });
                return ret;
            }
        }
    });

    function range(begin, end) {
        let a = [];
        for (let i = begin; i <= end; i++) {
            a[a.length] = i;
        }
        return a;
    }

    function choice(arr) {
        return arr[Math.floor(arr.length * Math.random())];
    }
}
