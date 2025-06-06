# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit dune

DESCRIPTION="Duration - conversions to various time units"
HOMEPAGE="https://github.com/hannesm/duration"
SRC_URI="https://github.com/hannesm/${PN}/archive/refs/tags/v${PV}.tar.gz
	-> ${P}.tar.gz"

LICENSE="ISC"
SLOT="0/${PV}"
KEYWORDS="~amd64 ~arm ~arm64 ~ppc ~ppc64 ~riscv ~x86"
IUSE="+ocamlopt test"
RESTRICT="!test? ( test )"

DEPEND="test? ( dev-ml/alcotest )"
