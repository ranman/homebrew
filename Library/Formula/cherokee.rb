require 'formula'

class Cherokee < Formula
  homepage 'http://cherokee-project.com/'

  stable do
    url "http://pkgs.fedoraproject.org/repo/pkgs/cherokee/cherokee-1.2.103.tar.gz/527b3de97ef9727bfd5f6832043cf916/cherokee-1.2.103.tar.gz"
    sha1 "8af2b93eb08f3719d21c7ae8fd94b9a99fb674c0"

    # OSX 10.9 patch
    patch do
      url "https://github.com/cherokee/webserver/commit/d0213768fdc6cf3aee61fe0be398d7825c01198f.patch"
      sha1 "4befeead2466c6ade6f2de5c39653e251f7dc365"
    end
  end

  head do
    url 'https://github.com/cherokee/webserver.git'

    depends_on :autoconf
    depends_on :automake
    depends_on :libtool
    depends_on 'wget' => :build
  end

  depends_on 'gettext'

  def install
    if build.head?
      ENV['LIBTOOL'] = 'glibtool'
      ENV['LIBTOOLIZE'] = 'glibtoolize'
      cmd = './autogen.sh'
    else
      cmd = './configure'
    end

    system cmd, "--disable-dependency-tracking",
                "--prefix=#{prefix}",
                "--sysconfdir=#{etc}",
                "--localstatedir=#{var}/cherokee",
                "--with-wwwuser=#{ENV['USER']}",
                "--with-wwwgroup=www",
                "--enable-internal-pcre",
                # Don't install to /Library
                "--with-wwwroot=#{etc}/cherokee/htdocs",
                "--with-cgiroot=#{etc}/cherokee/cgi-bin"
    system "make install"

    prefix.install "org.cherokee.webserver.plist"
    (prefix+'org.cherokee.webserver.plist').chmod 0644
    (share+'cherokee/admin/server.py').chmod 0755
  end

  def caveats
    <<-EOS.undent
      Cherokee is setup to run with your user permissions as part of the
      www group on port 80. This can be changed in the cherokee-admin
      but be aware the new user will need permissions to write to:
        #{var}/cherokee
      for logging and runtime files.

      By default, documents will be served out of:
        #{etc}/cherokee/htdocs

      And CGI scripts from:
        #{etc}/cherokee/cgi-bin

       If this is your first install, automatically load on startup with:
          sudo cp #{prefix}/org.cherokee.webserver.plist /Library/LaunchDaemons
          sudo launchctl load -w /Library/LaunchDaemons/org.cherokee.webserver.plist

      If this is an upgrade and you already have the plist loaded:
          sudo launchctl unload -w /Library/LaunchDaemons/org.cherokee.webserver.plist
          sudo cp #{prefix}/org.cherokee.webserver.plist /Library/LaunchDaemons
          sudo launchctl load -w /Library/LaunchDaemons/org.cherokee.webserver.plist
    EOS
  end
end
