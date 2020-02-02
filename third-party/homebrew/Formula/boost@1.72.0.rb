require_relative '../src/lib/boost_helper'

class BoostAT1720 < Formula
  desc 'Collection of portable C++ source libraries'
  homepage 'https://www.boost.org'
  helper = @helper = @@helper = BoostHelper.new('1.72.0') # rubocop:disable Style/ClassVars
  version helper.version
  url helper.url

  keg_only :versioned_formula

  bottle do
    root_url 'https://github.com/curoky/homebrew-tap/releases/download/bottles'
    sha256 x86_64_linux: '8cba0a18147eb5c0b6e86f2622e824ffda7a5f6c3f0f99d977e19738597f43fa'
  end

  depends_on :linux
  depends_on 'gcc@11' => :build
  depends_on 'bzip2'
  depends_on 'zlib'

  def install
    args = @@helper.install(prefix, lib)
    system './bootstrap.sh', *args[0]
    system './b2', 'headers'
    system './b2', *args[1]
  end

  def caveats
    @@helper.caveats(lib)
  end

  test do
    helper.test(testpath, include, lib)
  end
end
