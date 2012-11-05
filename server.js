// © 2012 Sami Majadla and Rapcities Inc. All Rights Reserved

var cluster = require('cluster'),
    numCPUs = require('os').cpus().length;

var files = {};
    
if(cluster.isMaster){
  console.log(numCPUs + ' cores on this machine.');
  for(var i = 0; i < numCPUs; i++)
    cluster.fork();
    
  cluster.on('exit', function(worker){
    console.log('worker ' + worker.process.pid + ' died.');
    cluster.fork();
  });
  process.on("SIGTERM", process.exit);
  process.on("SIGINT", process.exit);
  process.on("SIGKILL", process.exit);
  /*process.on("SIGTERM", websiteDown);
  process.on('exit',websiteDown);
  process.on('SIGINT', websiteDown);*/
}
else{
  connect = require('connect'),
  url = require('url'),
  path = require('path'),
  fs = require('fs');
  //artistInfo = require('./artistInfo');
  locations = require('./locs');
  users = require('./user');
  http = require('http');
  passport = require('passport');
  fpass = require('passport-facebook').Strategy;
  redistore = require('connect-redis')(connect);
  qs = require('querystring');

passport.serializeUser(function(userid,done){
	done(null, userid);
});
passport.deserializeUser(function(userid,done){
	done(null,userid);
});

passport.use(new fpass({
		//clientID:'300271166724919',
		//clientSecret:'b4ba0065d5002941b871610d00afd80b',
		clientID:'134659439991720', //rapcities proper
		clientSecret:'43c2b1a5bc972868418383d74a51bfa4', // DON'T FORGET TO SWITCH LOCALHOST HERE
		callbackURL:'http://projectandroid.rapcities.com/auth/facebook/callback',
		passReqToCallback: true
	},
	function(req, accessToken, refreshToken, fbUserData, done){
		console.log('facebook user data:\n\n'+JSON.stringify(fbUserData));
		console.log('accessToken: \n\n'+accessToken+'\nrefresh:\n\n'+refreshToken+'\nJSLKDJF\n\n\n');
		var toUpload = {
			'name':fbUserData._json.name,
			'email':fbUserData._json.email,
			'fbid':fbUserData._json.id,
			'accessToken':accessToken
		}
		users.createUser(toUpload, function (err, id) {
		      if (err) { return done(err); }
		      done(null, id);
		}, req.session);
	}
));
	function returnNone(res){
		res.writeHead(404);
		res.end();
	}
	
	function authRouter(req,res,next){
		var arr = req.url.split('?')[0];
	    switch(arr){
	    	case '/loc/newtype': locations.newType(req,res); break;
			case '/loc/getTypeIconID': locations.getTypeIconID(req,res); break;
			case '/loc/newloc': locations.newLoc(req,res); break;
			case '/loc/deleteLoc': locations.deleteLoc(req,res); break;
			case '/loc/search': locations.searchLoc(req,res); break;
			case '/loc/editLoc': locations.editLoc(req,res); break;
			case '/loc/editLocation': locations.editLocation(req,res); break;
			case '/loc/edittype': locations.editType(req,res); break;
			case '/loc/addCity': locations.addCity(req,res); break;
			case '/loc/createAnalogue': locations.createAnalogue(req,res); break;
			default: res.writeHead(500); 
					res.end();
		}
	}
	
	function router(req, res, next) {
	    var arr = req.url.split('?')[0];

	    switch(arr){
			case '/user/getInfo': users.getInfo(req,res); break;/////
			case '/user/lastLocation': users.lastLocation(req,res); break;/////
			case '/loc/getTypes': locations.getTypes(req,res); break;
			case '/loc/getTypeIcon': locations.getTypeIcon(req,res); break;
			case '/loc/browse': locations.browseLoc(req,res); break;
			case '/loc/view': locations.view(req,res); break;
			case '/loc/getCities': locations.getCities(req,res); break;/////
			default: 
				if(req.user && authorized(req.user))
					next();
				else{
					res.writeHead(500); 
					res.end();
				}
    	}
	}

function authorized(req){
	if(req == '5095d8ad7006713d02000001' || req == '50972058a3d8967249000001' || req == '5097247a7e39dc405f000001' || req == '5097bb4e407230fa7b000001')
		return true;
	else return false;
}

	function checkWWW(req, res, next){
		if(req.headers.host.match(/^www/)){
			console.log('www');
			res.writeHead(301, {'location':'http://'+req.headers.host.replace(/^www\./,'')+req.url});
			res.end();
		} 
		else
			next();
	}
	
	function checkLoggedIn(req, res, next){
		var path = req.url.split('?')[0];
		if(path == '/robots.txt'){
			res.writeHead(404);
        	res.end();
        }		      
		else if(path == '/opensesame'){
			passport.authenticate('facebook', {scope: ['email']})(req,res,next);
			return;
		}
		else if(path == '/auth/facebook/callback'){
			console.log('regular callback');
			passport.authenticate('facebook', {failureRedirect: '/failbook', 'successRedirect':'/'})(req, res, next);
			return;
		}
		else if(path == '/failbook'){
			console.log('failed log in');
			res.writeHead(401);
			res.end('Your login attempt with Facebook failed. If this is an error, please try logging in again or get in touch with Facebook.');
			return;
		}
		else{
			next();
		}
	}
	
  connect.createServer(
	connect.favicon(__dirname+'/files/icons/favicon.ico'),
	checkWWW,
	connect.logger(),
	connect.cookieParser(),
	connect.bodyParser(),
	connect.session({store: new redistore, secret:'jiInppplym87543dxj'}),
	connect.query(),
	passport.initialize(),
	passport.session(),
	checkLoggedIn,
    require('./fileServer')(),
    connect.compress({memLevel:9}),
	router,
    authRouter).listen(80);
	//authRouter).listen(8888);
  console.log('Server has started.');
}

