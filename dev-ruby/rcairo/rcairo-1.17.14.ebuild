# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

USE_RUBY="ruby31 ruby32 ruby33"

RUBY_FAKEGEM_NAME="cairo"

RUBY_FAKEGEM_TASK_TEST=""

RUBY_FAKEGEM_DOCDIR="doc"

RUBY_FAKEGEM_EXTRADOC="AUTHORS NEWS"

RUBY_FAKEGEM_EXTENSIONS=(ext/cairo/extconf.rb)

inherit ruby-fakegem

DESCRIPTION="Ruby bindings for cairo"
HOMEPAGE="https://cairographics.org/rcairo/"

LICENSE="|| ( Ruby-BSD GPL-2 )"

SLOT="0"
KEYWORDS="amd64 ~ppc ~riscv ~x86"

IUSE="test"

RDEPEND=">=x11-libs/cairo-1.2.0[svg(+)]"
DEPEND=">=x11-libs/cairo-1.2.0[svg(+)]"

ruby_add_rdepend "dev-ruby/red-colors"

ruby_add_bdepend "
	>=dev-ruby/pkg-config-1.2.2
	dev-ruby/ruby-glib2
	test? ( >=dev-ruby/test-unit-2.1.0-r1:2 dev-ruby/ruby-poppler )"

all_ruby_prepare() {
	# Avoid unneeded dependency
	sed -e '/native-package-installer/ s:^:#:' \
		-e '/def required_pkg_config_package/areturn true' \
		-e '/checking_for/,/^end/ s:^:#:' \
		-i ext/cairo/extconf.rb || die
	sed -i -e '/native-package-installer/,/Gem::Dependency/ d' ../metadata || die

	# Avoid test that requires unpackaged fixture
	sed -i -e '/sub_test_case..FreeTypeFontFace/,/^  end/ s:^:#:' test/test_font_face.rb || die

	# Bug 790131
	sed -i -e '/^install-headers:/s!$! $(TIMESTAMP_DIR)/.sitearchdir.time!' \
		ext/cairo/depend || die
}

each_ruby_test() {
	# don't rely on the Rakefile because it's a mess to load with
	# their hierarchy, do it manually.
	${RUBY} -Ilib -r ./test/helper \
		-e 'gem "test-unit"; require "test/unit"; Dir.glob("test/**/test_*.rb") {|f| load f}' || die "tests failed"
}

each_ruby_install() {
	each_fakegem_install

	insinto $(ruby_get_hdrdir)
	doins ext/cairo/rb_cairo.h
}

all_ruby_install() {
	all_fakegem_install

	dodoc -r samples
}
