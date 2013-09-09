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

        private static function hasAllNumbers(domain:String):Boolean {
            var parts:Array = domain.split(".");
            for (var i:int = 0; i < parts.length; i++) {
                if (! isNumber(parts[i])) {
                    return false;
                }
            }
            return true;
        }

        private static function parseIPAddressDomain(domain:String):String {
            var parts:Array = domain.split(".");
            if (parts.length <= 2) return domain;
            return parts[parts.length - 2] + "." + parts[parts.length - 1];
        }

        private static function isNumber(n:String):Boolean {
           return !isNaN(parseFloat(n)) && isFinite(n as Number);
        }

       public static function stripSubdomain(host:String):String {
          var secondaries:Array = ('co.uk,org.uk,ltd.uk,plc.uk,me.uk,br.com,cn.com,eu.com,hu.com,no.com,qc.com,sa.com' +
             'se.com,se.net,us.com,uy.com,co.ac,gv.ac,or.ac,ac.ac,ac.at,co.at,gv.at,or.at' +
             'asn.au,com.au,edu.au,org.au,net.au,id.au,ac.be,adm.br,adv.br,am.br,arq.br,art.br' +
             'bio.br,cng.br,cnt.br,com.br,ecn.br,eng.br,esp.br,etc.br,eti.br,fm.br,fot.br,fst.br' +
             'g12.br,gov.br,ind.br,inf.br,jor.br,lel.br,med.br,mil.br,net.br,nom.br,ntr.br' +
             'odo.br,org.br,ppg.br,pro.br,psc.br,psi.br,rec.br,slg.br,tmp.br,tur.br,tv.br,vet.br' +
             'zlg.br,ab.ca,bc.ca,mb.ca,nb.ca,nf.ca,ns.ca,nt.ca,on.ca,pe.ca,qc.ca,sk.ca,yk.ca' +
             'ac.cn,com.cn,edu.cn,gov.cn,org.cn,bj.cn,sh.cn,tj.cn,cq.cn,he.cn,nm.cn,ln.cn' +
             'jl.cn,hl.cn,js.cn,zj.cn,ah.cn,gd.cn,gx.cn,hi.cn,sc.cn,gz.cn,yn.cn,xz.cn,sn.cn' +
             'gs.cn,qh.cn,nx.cn,xj.cn,tw.cn,hk.cn,mo.cn,com.ec,tm.fr,com.fr,asso.fr,presse.fr' +
             'co.il,net.il,ac.il,k12.il,gov.il,muni.il,ac.in,co.in,org.in,ernet.in,gov.in' +
             'net.in,res.in,ac.jp,co.jp,go.jp,or.jp,ne.jp,ac.kr,co.kr,go.kr,ne.kr,nm.kr,or.kr' +
             'asso.mc,tm.mc,com.mm,org.mm,net.mm,edu.mm,gov.mm,org.ro,store.ro,tm.ro,firm.ro' +
             'www.ro,arts.ro,rec.ro,info.ro,nom.ro,nt.ro,com.sg,org.sg,net.sg,gov.sg,ac.th,co.th' +
             'go.th,mi.th,net.th,or.th,com.tr,edu.tr,gov.tr,k12.tr,net.tr,org.tr,com.tw,org.tw' +
             'net.tw,ac.uk,uk.com,uk.net,gb.com,gb.net,com.hk,org.hk,net.hk,edu.hk,eu.lv,co.nz' +
             'org.nz,net.nz,maori.nz,iwi.nz,com.pt,edu.pt,com.ve,net.ve,org.ve,web.ve,info.ve' +
             'co.ve,net.ru,org.ru,com.hr,tv.tr,com.qa,edu.qa,gov.qa,gov.au,com.my,edu.my,gov.my' +
             'co.za,com.ar,com.pl,com.ua,biz.pl,biz.tr,co.gl,co.mg,co.ms,co.vi,co.za,com.ag' +
              'com.ai,com.cy,com.de,com.do,com.es,com.fj,com.gl,com.gt,com.hu,com.kg,com.ki' +
              'com.lc,com.mg,com.ms,com.mt,com.mu,com.mx,com.nf,com.ng,com.ni,com.pa,com.ph' +
              'com.ro,com.ru,com.sb,com.sc,com.sv,de.com,de.org,firm.in,gen.in,idv.tw,ind.in' +
              'info.pl,info.tr,kr.com,me.uk,net.ag,net.ai,net.cn,net.do,net.gl,net.kg,net.ki' +
              'net.lc,net.mg,net.mu,net.ni,net.pl,net.sb,net.sc,nom.ni,off.ai,org.ag,org.ai' +
              'org.do,org.es,org.gl,org.kg,org.ki,org.lc,org.mg,org.ms,org.nf,org.ni,org.pl' +
              'org.sb,org.sc').split(',');

          host = host.toLowerCase();
          var bits:Array = host.split(".");

          if (bits.length < 2) return host;

          var secondary:String = bits.slice(bits.length - 2).join('.');
          if (bits.length >= 3 && secondaries.indexOf(secondary) >= 0) {
             return bits.slice(bits.length - 3).join('.');
          }
          return bits.slice(bits.length - 2).join('.');
       }

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

        public static function isLocal(url:String):Boolean {
            trace("localDomain? " + url);
            if (url.indexOf("http://localhost") == 0) return true;
            if (url.indexOf("http://localhost:") == 0) return true;
            if (url.indexOf("file://") == 0) return true;
            if (url.indexOf("http://127.0.0.1") == 0) return true;
            if (url.indexOf("http://") == 0) return false;
            if (url.indexOf("/") == 0) return true;
            return false;
        }

        public static function allowCodeLoading(resourceUrl:String):Boolean {
            if (! URLUtil.isCompleteURLWithProtocol(resourceUrl)) return true;
            var playerUrl:String = URLUtil.playerBaseUrl;

            if (isLocal(playerUrl)) return true;

            var playerDomain:String = parseDomain(playerUrl, true);
            var resourceDomain:String = parseDomain(resourceUrl, true);

            trace("player domain " + playerDomain);
            trace("resource domain " + resourceDomain);
            return playerDomain == resourceDomain;
        }
    }
}
