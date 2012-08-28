/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Anssi Piirainen, <api@iki.fi>
 *
 * Copyright (c) 2008-2011 Flowplayer Oy
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */
package org.flowplayer.util {
    public class DomainUtil {

        /**
         * Parses and returns the domain name from the specified URL.
         * @param url
         * @param stripSubdomains if true the top private domain name is returned with other subdomains stripped out
         * @return
         */
        public static function parseDomain(url:String, stripSubdomains:Boolean):String {
            var domain:String = getDomain(url);
            if (stripSubdomains || domain.indexOf("www.") == 0) {
                if (hasAllNumbers(domain)) {
                    trace("IP address in URL");
                    return parseIPAddressDomain(domain);
                }

                domain = stripSubdomain(domain);
                trace("stripped out subdomain, resulted in " + domain);
            }
            return domain.toLowerCase();
        }

        private static function parseIPAddressDomain(domain:String):String {
            var parts:Array = domain.split(".");
            if (parts.length <= 2) return domain;
            return parts[parts.length - 2] + "." + parts[parts.length - 1];
        }

        private static function hasAllNumbers(domain:String):Boolean {
            var parts:Array = domain.split(".");
            for (var i:int = 0; i < parts.length; i++) {
                if (! isNumber(parts[i])) {
                    return false;
                }
            }
            return true;
        }

        private static function isNumber(n:String):Boolean {
            return !isNaN(parseFloat(n)) && isFinite(n as Number);
        }

        public static function stripSubdomain(domain:String):String {
            if (! domain) return domain;
            domain = domain.toLocaleLowerCase();
            trace("stripSubdomain()");
            var tlds:Array = new Array('.com','.net','.org','.biz','.ws','.in','.me','.co','.co.uk','.org.uk','.ltd.uk',
                    '.plc.uk','.me.uk','.edu','.mil','.br.com','.cn.com','.eu.com','.hu.com','.no.com','.qc.com',
                    '.sa.com','.se.com','.se.net','.us.com','.uy.com','.ac','.co.ac','.gv.ac','.or.ac','.ac.ac',
                    '.af','.am','.as','.at','.ac.at','.co.at','.gv.at','.or.at','.asn.au','.com.au','.edu.au',
                    '.org.au','.net.au','.id.au','.be','.ac.be','.br','.adm.br','.adv.br','.am.br','.arq.br',
                    '.art.br','.bio.br','.cng.br','.cnt.br','.com.br','.ecn.br','.eng.br','.esp.br','.etc.br',
                    '.eti.br','.fm.br','.fot.br','.fst.br','.g12.br','.gov.br','.ind.br','.inf.br','.jor.br',
                    '.lel.br','.med.br','.mil.br','.net.br','.nom.br','.ntr.br','.odo.br','.org.br','.ppg.br',
                    '.pro.br','.psc.br','.psi.br','.rec.br','.slg.br','.tmp.br','.tur.br','.tv.br','.vet.br',
                    '.zlg.br','.ca','.ab.ca','.bc.ca','.mb.ca','.nb.ca','.nf.ca','.ns.ca','.nt.ca','.on.ca',
                    '.pe.ca','.qc.ca','.sk.ca','.yk.ca','.cc','.cn','.ac.cn','.com.cn','.edu.cn','.gov.cn',
                    '.org.cn','.bj.cn','.sh.cn','.tj.cn','.cq.cn','.he.cn','.nm.cn','.ln.cn','.jl.cn','.hl.cn',
                    '.js.cn','.zj.cn','.ah.cn','.gd.cn','.gx.cn','.hi.cn','.sc.cn','.gz.cn','.yn.cn','.xz.cn',
                    '.sn.cn','.gs.cn','.qh.cn','.nx.cn','.xj.cn','.tw.cn','.hk.cn','.mo.cn','.cx','.cz','.de',
                    '.dk','.fo','.com.ec','.fr','.tm.fr','.com.fr','.asso.fr','.presse.fr','.gf','.gs','.co.il',
                    '.net.il','.ac.il','.k12.il','.gov.il','.muni.il','.ac.in','.co.in','.org.in','.ernet.in',
                    '.gov.in','.net.in','.res.in','.is','.it','.ac.jp','.co.jp','.go.jp','.or.jp','.ne.jp',
                    '.ac.kr','.co.kr','.go.kr','.ne.kr','.nm.kr','.or.kr','.li','.lt','.lu','.asso.mc','.tm.mc',
                    '.com.mm','.org.mm','.net.mm','.edu.mm','.gov.mm','.ms','.nl','.no','.nu','.pl','.ro',
                    '.org.ro','.store.ro','.tm.ro','.firm.ro','.www.ro','.arts.ro','.rec.ro','.info.ro','.nom.ro',
                    '.nt.ro','.se','.si','.com.sg','.org.sg','.net.sg','.gov.sg','.sk','.st','.tf','.ac.th',
                    '.co.th','.go.th','.mi.th','.net.th','.or.th','.tm','.to','.com.tr','.edu.tr','.gov.tr',
                    '.k12.tr','.net.tr','.org.tr','.com.tw','.org.tw','.net.tw','.ac.uk','.uk.com','.uk.net',
                    '.gb.com','.gb.net','.vg','.sh','.kz','.ch','.info','.ua','.gov','.name','.pro','.ie','.hk',
                    '.com.hk','.org.hk','.net.hk','.edu.hk','.us','.tk','.cd','.by','.ad','.lv','.eu.lv','.bz',
                    '.es','.jp','.cl','.ag','.mobi','.eu','.co.nz','.org.nz','.net.nz','.maori.nz','.iwi.nz','.io',
                    '.la','.md','.sc','.sg','.vc','.tw','.travel','.my','.se','.tv','.pt','.com.pt','.edu.pt',
                    '.asia','.fi','.com.ve','.net.ve','.fi','.org.ve','.web.ve','.info.ve','.co.ve','.tel','.im',
                    '.gr','.ru','.net.ru','.org.ru','.hr','.com.hr','.tv.tr','.aero', '.cat', '.coop', '.int',
                    '.jobs', '.museum', '.xxx','.com.qa','.edu.qa','.gov.qa',
                    '.gov.au','.com.my','.edu.my','.gov.my');

            var bits:Array = domain.split('.');

            if (bits.length >= 3 && tlds.indexOf("." + bits[bits.length - 2] + "." + bits[bits.length - 1]) >= 0) {
                return bits[bits.length - 3] + "." +  bits[bits.length - 2] + "." + bits[bits.length - 1];
            }
            if (tlds.indexOf("." + bits[bits.length - 1]) >= 0) {
                return bits[bits.length - 2] + "." + bits[bits.length - 1];
            }
            if (bits.length > 2) {
                return bits[bits.length - 2] + "." + bits[bits.length - 1];
            }
            return domain;
        }

        /**
         * Strips subdomains from the specified domain.
         *
         * @param domain
         * @return
         */
//        public static function stripSubdomain(domain:String):String {
//            if (! domain) return null;
//            var inetDomain:InternetDomainName = new InternetDomainName(domain);
//
//            // return null if the domain is a public TLD like com, ac.uk, us.com
//            if (inetDomain.isPublicSuffix()) return null;
//
//            // return the top private domain name that is directly under the public suffix
//            // if the domain is not under a public suffix (intranet domains for example) we return the
//            // domain untouched.
//            return inetDomain.isUnderPublicSuffix() ? inetDomain.topPrivateDomain.name : inetDomain.name;
//        }

        public static function getDomain(url:String):String {
            var schemeEnd:int = getSchemeEnd(url);
            var domain:String = url.substr(schemeEnd);
            var endPos:int = getDomainEnd(domain);
            return domain.substr(0, endPos).toLowerCase();
        }

        internal static function getSchemeEnd(url:String):int {
            var pos:int = url.indexOf("///");
            if (pos >= 0) return pos + 3;
            pos = url.indexOf("//");
            if (pos >= 0) return pos + 2;
            return 0;
        }

        internal static function getDomainEnd(domain:String):int {
            var colonPos:int = domain.indexOf(":");
            var pos:int = domain.indexOf("/");
            if (colonPos > 0 && pos > 0 && colonPos < pos) return colonPos;
            if (pos > 0) return pos;

            pos = domain.indexOf("?");
            if (pos > 0) return pos;
            return domain.length;
        }

    }
}
