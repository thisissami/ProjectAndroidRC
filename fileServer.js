// © 2012 Sami Majadla and Rapcities Inc. All Rights Reserved

var fs = require('fs'),
  utils = require(__dirname + '/node_modules/connect/lib/utils'),
  zlib = require('zlib'),
  gzip = zlib.createGzip(),
  url = require('url'),
  files = {};
  //indexCreator = require('./indexCreator');

/**
 *   - `maxAge`  cache-control max-age directive, defaulting to 1 day
 *
 */

module.exports = function fileServer(maxage){
  var maxAge = maxage || 86400000;

  return function fileServer(req, res, next){
	var found = true;
	var pathname = req.url.split('?')[0];
    switch(pathname){
      case('/robots.txt'):
        res.writeHead(404);
        res.end();
        break;
      case('/areyouateapot'):
        res.writeHead(418);
        res.end('check the header!');
        break;
      case('/'):
	  case('/#_=_'):
		var host;
		console.log(req.headers.host);
		if(req.headers.host == 'projectandroid.rapcities.com'){
			host = 'Kanye';
		}
        if(host){
			if(files[host+'index']) sendfile(host+'index',true);
        	else readfile('/files/html/'+host+'.html','text/html; charset=utf-8',host+'index',true,true);
		}else{
			res.writeHead(500); 
			res.end();
		}
        break;
      case('/processing-1.3.6.min.js'):
        if (files.processingmin) sendfile('processingmin',true);
        else readfile('/files/lib/processing-1.3.6.min.js','text/javascript','processingmin',true)
        break;
      case('/soundmanager2.js'):
        if (files.sm2) sendfile('sm2',true);
        else readfile('/files/lib/soundmanager2-nodebug-jsmin.js','text/javascript','sm2',true)
        break;
      case('/soundmanager2.swf'):
        if (files.sm2f) sendfile('sm2f');
        else readfile('/files/lib/soundmanager2.swf','application/x-shockwave-flash','sm2f',false)
        break;
	  case('/upl0dder'):
	 	if(req.user == '5095d8ad7006713d02000001' || req.user == '50972058a3d8967249000001' || req.user == '5097247a7e39dc405f000001' || req.user == '504ca29e27a07c1c1500001f'){		
			if (files.upl0dder) sendfile('upl0dder',true);
			else readfile('/files/locs/upload.html','text/html','upl0dder',true,true)
	      }
		  break;
	  case('/jquery-ui-1.8.18.custom.css'):
		if (files.jqcss) sendfile('jqcss',true);
		else readfile('/files/css/jquery-ui-1.8.18.custom.css','text/css','jqcss',true)
		break;
	  case('/images/ui-icons_454545_256x240.png'):
	    if (files.icon1) sendfile('icon1');
	    else readfile('/files/images/ui-icons_454545_256x240.png','image/png','icon1',false)
	    break;
	  case('/images/ui-icons_cccccc_256x240.png'):
	    if (files.icon2) sendfile('icon2');
	    else readfile('/files/images/ui-icons_cccccc_256x240.png','image/png','icon2',false)
	    break;
	  case('/images/ui-bg_highlight-soft_75_000000_1x100.png'):
	    if (files.bg2) sendfile('bg2');
	    else readfile('/files/images/ui-bg_highlight-soft_75_000000_1x100.png','image/png','bg2',false)
	    break;
	  case('/images/ui-bg_flat_75_000000_40x100.png'):
	    if (files.bg1) sendfile('bg1');
	    else readfile('/files/images/ui-bg_highlight-soft_75_000000_1x100.png','image/png','bg1',false)
	    break;
	  case('/heart.svg'):
        if (files.heart) sendfile('heart');
		else readfile('/files/icons/heart.svg', 'image/svg+xml', 'heart', false);
	    break;
	  case('/greyHeart.svg'):
		if (files.greyHeart) sendfile('greyHeart');
	    else readfile('/files/icons/greyHeart.svg', 'image/svg+xml', 'greyHeart', false);
	    break;
	  case('/processing.js'):
		if (files.processingjs) sendfile('processingjs',true);
       	else readfile('/files/lib/processing.js', 'text/javascript', 'processingjs', true);
       	break;
	  case('/logosign'):
		if (files.logo) sendfile('logosign');
       	else readfile('/files/images/logosign.png', 'image/png', 'logosign', false);
       	break;
	  case('/fblogo.jpg'):
		if (files.fblogo) sendfile('fblogo');
       	else readfile('/files/images/fblogo.jpg', 'image/jpg', 'fblogo', false);
       	break;
	  case('/info'):
		if (files.info) sendfile('info');
       	else readfile('/files/icons/info.png', 'image/png', 'info', false);
       	break;
	  case('/whatisRC.png'):
		if (files.whatisrc) sendfile('whatisrc');
       	else readfile('/files/images/whatisrc.png', 'image/png', 'whatisrc', false);
       	break;
	  case('/welcomeFB.png'):
		if (files.welcomeFB) sendfile('welcomeFB');
       	else readfile('/files/images/welcomeFB.png', 'image/png', 'welcomeFB', false);
       	break;
	  case('/storePreview.png'):
		if (files.storePreview) sendfile('storePreview');
       	else readfile('/files/images/storePreview.png', 'image/png', 'storePreview', false);
       	break;
	  case('/facebook'):
		if (files.facebook) sendfile('facebook');
       	else readfile('/files/icons/facebook.png', 'image/png', 'facebook', false);
       	break;
      case('/exit.png'):
		if (files.exit) sendfile('exit');
       	else readfile('/files/icons/exit.png', 'image/png', 'exit', false);
       	break;
	  case('/likesign.png'):
		if(files.likesign) sendfile('likesign');
		else readfile('/files/images/likesign.png','image/png','likesign',false);
		break;
	  case('/streetCoins.jpg'):
		if(files.streetCoins) sendfile('streetCoins');
		else readfile('/files/icons/streetCoins.jpg','image/jpg','streetcoins',false);
		break;
      case('/wikibio.png'):
		if (files.wikibio) sendfile('wikibio');
       	else readfile('/files/icons/wikibio.png', 'image/png', 'wikibio', false);
       	break;
	  case('/heartbasket.png'):
		if (files.heartbasket) sendfile('heartbasket');
       	else readfile('/files/icons/heartbasket.png', 'image/png', 'heartbasket', false);
       	break;
	  case('/miniNYC.png'):
		if (files.miniNYC) sendfile('miniNYC');
       	else readfile('/files/images/miniNYC.png', 'image/png', 'miniNYC', false);
       	break;
	  default: found = false;
    } 
	
	  var folder,contentType;
	 
    var requrl = url.parse(req.url, true).pathname;
    if(requrl.indexOf('/css/') == 0) {
      var strippedString = requrl.replace('/', '');
      if(files[strippedString]) sendfile(strippedString)
      else readfile('/files' + requrl, 'text/css', strippedString, true);
		found = true;
    } else if(requrl.indexOf('/js/') == 0) {
      var strippedString = requrl.replace('/', '');
      if(files[strippedString]) sendfile(strippedString)
      else readfile('/files' + requrl, 'text/javascript', strippedString, true);
		found = true;
    }/* else if(req.url == '/upl0d.pde'){                        // FROM HERE PLZ!
		folder = __dirname + '/files/locs/uploadxy.pde';
		contentType = 'text/processing';
	}
	else if(req.url == '/indexold.html'){
        folder = __dirname + '/pde/indexold.html';
        contentType = 'text/html; charset=utf-8';
      }
	else if(req.url == '/rapcities.pde'){
        folder = __dirname + '/pde/rapcitiesAlpha.pde';
        contentType = 'text/processing';
      }//*/
	else if(req.url.split('/')[1] == 'pl0dder'){
		if(req.user == '5095d8ad7006713d02000001' || req.user == '50972058a3d8967249000001' || req.user == '5097247a7e39dc405f000001' || req.user == '504ca29e27a07c1c1500001f'){		
			if(req.url.split('/').length > 2){
				var host = req.url.split('/')[2];
				switch(host){
					case('Kanye'):
					case('Gaga'):
						if(files[host+'plod']) sendfile(host+'plod',true);
			        	else readfile('/files/locs/'+host+'Uploader.html','text/html; charset=utf-8',host+'plod',true,true);
						found = true;
						break;
					default:
						res.writeHead(500); 
						res.end();
						return;
				}
			}
		}
	}

	  else{
		var ext = path.extname(pathname);
		if(ext == '.grid'){
			var gridarray = req.url.split('.');
			if(gridarray.length == 3){
				var folderPath = '/files/grid/'+gridarray[1]+'_'+gridarray[0].split('/')[1]+'.png';
				if (files[folderPath]) sendfile(folderPath);
		       	else readfile(folderPath, 'image/png', folderPath, false);
				found = true;
			}
		}
	}
 
      if(folder){
        fs.readFile(folder, function(error, content){
          if(error){
            res.writeHead(500);
            res.end();
          }
          else{
            res.writeHead(200, {'Content-Type': contentType});
            res.end(content);
          }
        });
      }else if(!found){console.log(req.url); next();}
    
console.log(found + req.url);
 //icon, index, sm2, sm2f, sm2f9, processing, info, fbook, ytube;   
    function sendfile(file,compress){
      var acceptEncoding = req.headers['accept-encoding'];
      if (!acceptEncoding || !compress) {
		res.writeHead(200, files[file].headers);
        res.end(files[file].body);
      }
      else if (acceptEncoding.trim() == '*' || acceptEncoding.match(/\bgzip\b/)) {
        res.writeHead(200, files[file+'g'].headers);
        res.end(files[file+'g'].body);
      }
      else if (acceptEncoding.match(/\bdeflate\b/)) {
        res.writeHead(200, files[file+'d'].headers);
        res.end(files[file+'d'].body);
      }
      else{ 
        res.writeHead(200, files[file].headers);
        res.end(files[file].body);
      }
    }
    //if compress, then create gzip and deflate as well, otherwise, just a regular copy
    function readfile(path,contentType,file,compress,noCache){
      fs.readFile(__dirname + path, function(err, buf){
        if (err) return next(err);
		var headers = {
           'Content-Type': contentType,
           'Content-Length': buf.length,
           'ETag': '"' + utils.md5(buf) + '"'
			};
		if(noCache){
			headers['Cache-Control'] = 'no-cache, no-store, must-revalidate';
			headers['Pragma'] = 'no-cache';
		}
		else
			headers['Cache-Control'] = 'public, max-age=' + (maxAge / 1000);
        
        files[file] = {	headers: headers, body: buf };

        if(compress){
          zlibBuffer(zlib.createGzip({level:zlib.Z_BEST_COMPRESSION,memLevel:zlib.Z_MAX_MEMLEVEL}),buf,function(err,gzip){
			var headerz = {
	           'Content-Type': contentType,
               'Content-Encoding':'gzip',
               'Content-Length': gzip.length,
               'ETag': '"' + utils.md5(gzip) + '"'
				};
			if(noCache){
				headerz['Cache-Control'] = 'no-cache, no-store, must-revalidate';
				headerz['Pragma'] = 'no-cache';
			}
			else
				headerz['Cache-Control'] = 'public, max-age=' + (maxAge / 1000);
			
            files[file+'g'] = { headers: headerz, body: gzip };
          });
          zlibBuffer(zlib.createDeflate({level:zlib.Z_BEST_COMPRESSION,memLevel:zlib.Z_MAX_MEMLEVEL}),buf,function(err,deflate){
            var headerz = {
	           'Content-Type': contentType,
               'Content-Encoding':'deflate',
               'Content-Length': deflate.length,
               'ETag': '"' + utils.md5(deflate) + '"'
				};
			if(noCache){
				headerz['Cache-Control'] = 'no-cache, no-store, must-revalidate';
				headerz['Pragma'] = 'no-cache';
			}
			else
				headerz['Cache-Control'] = 'public, max-age=' + (maxAge / 1000);
			
			files[file+'d'] = { headers: headerz, body: deflate };
          });
        }
        res.writeHead(200, files[file].headers);
        res.end(buf);
      });
    }
    //zippify!
    function zlibBuffer(engine, buffer, callback) {
      var buffers = [];
      var nread = 0;

      engine.on('error', function(err) {
        engine.removeListener('end');
        engine.removeListener('error');
        callback(err);
      });

      engine.on('data', function(chunk) {
        buffers.push(chunk);
        nread += chunk.length;
      });

      engine.on('end', function() {
        var buffer;
        switch(buffers.length) {
          case 0:
            buffer = new Buffer(0);
            break;
          case 1:
            buffer = buffers[0];
            break;
          default:
            buffer = new Buffer(nread);
            var n = 0;
            buffers.forEach(function(b) {
              var l = b.length;
              b.copy(buffer, n, 0, l);
              n += l;
            });
            break;
        }
        callback(null, buffer);
      });

      engine.write(buffer);
      engine.end();
    }
  };
};
