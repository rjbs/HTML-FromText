use ExtUtils::MakeMaker;

WriteMakefile (
               AUTHOR        => 'Casey West <casey@geeknest.com>',
               ABSTRACT      => "Convert Plain Text to HTML",
               NAME          => 'HTML::FromText',
               VERSION_FROM  => 'lib/HTML/FromText.pm',
               PREREQ_PM     => {
                                 'Scalar::Util'          =>  '1.12',
                                 'HTML::Entities'        =>  '1.26',
                                 'Regexp::Common'        =>  '2.113',
                                 'Text::Tabs'            => '98.1128',
                                 'Email::Find::addrspec' =>  '0.09',
                                 'Exporter::Lite'        =>  '0.01',
                                 'Test::More'            =>  '0.47',
                                },
              );
