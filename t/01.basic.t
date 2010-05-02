use strict;
use Test::More;
use WWW::Tube8;

my $ua = LWP::UserAgent->new(
    agent   => 'WWW::Tube8.test',
    timeout => 5,
);
my $res = $ua->get("http://www.tube8.com/");
my $online = $res->is_success;

if($online){
    plan tests => 17;
}else{
    plan skip_all => ": you're offline or tube8.com is down, so skiped all tests.";
}

{
    eval {
        my $t8 = WWW::Tube8->new;
    };
    like $@, qr/opt needs hash ref/, 'new : not hash';
}

{
    eval {
        my $t8 = WWW::Tube8->new({});
    };
    like $@, qr/url is required/, 'new : no url';
}

{
    eval {
        my $t8 = WWW::Tube8->new({ url => 'http://www.example.com/' });
    };
    like $@, qr/url is wrong/, 'new : not tube8 url';
}

{
    my $t8 = WWW::Tube8->new({
        url => 'http://www.tube8.com/blowjob/saki-ninomiya/228561/',
        ua  => $ua,
    });

    isa_ok $t8, 'WWW::Tube8', 'new : WWW::Tube8';

    is $t8->{ua}->agent, 'WWW::Tube8.test', 'new : agent';

    like $t8->flv,
         qr/^http:\/\/.+\.tube8\.com\/flv\/.+\.flv/,
         'flv : get url of flv file';

    like $t8->thumb,
       qr/^http:\/\/www\.tube8\.com\/.+\.jpg/,
       'thumb : get url of thumbnail file';

    like $t8->get_3gp,
         qr/^http:\/\/.+\.tube8\.com\/flv\/.+\.3gp/,
         'get_3gp : get url of 3gp file';

    is $t8->url,
       'http://www.tube8.com/blowjob/saki-ninomiya/228561/',
       'url : get url of video';

    is $t8->id, '228561', 'id : get id of video';

    is $t8->title, 'saki ninomiya', 'title : get title of video';

    is $t8->title_inurl,
       'saki-ninomiya',
       'title_inurl : get title of video for url';

    is $t8->category, 'Blowjob', 'category : get category of video';

    is $t8->category_url,
       'http://www.tube8.com/cat/blowjob/7/',
       'category_url : get category link of video';

    is $t8->duration, '06:58', 'duration : get duration of video';

    is ref $t8->related_videos,
       'ARRAY',
       'related_videos : get related videos list';

    # rewrite url for test
    $t8->url('http://www.example.com/test/hoge-hage-foo-bar/77777/');
    eval { $t8->_get_info; }; # it is no good to do like that. for test only.
    like $@, qr/can't get tube8 page/, '_get_info : wrong url';
}




