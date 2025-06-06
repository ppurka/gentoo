# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit bash-completion-r1 go-module toolchain-funcs
GIT_COMMIT=dd5d320e41b5451cdf3c01891bc4e13d189586ed
GIT_COMMIT_SHORT=${GIT_COMMIT:0:9}

DESCRIPTION="Local kubernetes clusters for learning and development"
HOMEPAGE="https://github.com/kubernetes/minikube https://kubernetes.io"

SRC_URI="https://github.com/kubernetes/minikube/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	https://dev.gentoo.org/~zmedico/dist/${P}-deps.tar.xz"

LICENSE="Apache-2.0 BSD BSD-2 CC-BY-4.0 CC-BY-SA-4.0 CC0-1.0 GPL-2 ISC LGPL-3 MIT MPL-2.0 WTFPL-2 ZLIB || ( LGPL-3+ GPL-2 ) || ( Apache-2.0 LGPL-3+ ) || ( Apache-2.0 CC-BY-4.0 )"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="hardened libvirt"

COMMON_DEPEND="libvirt? ( app-emulation/libvirt:=[qemu] )"
DEPEND="${COMMON_DEPEND}"
RDEPEND="${COMMON_DEPEND}"
BDEPEND="dev-go/go-bindata"

RESTRICT="test"

src_unpack() {
	default
}

src_prepare() {
	ln -sv ../vendor ./ || die
	default
}

src_configure() {
	case "${ARCH}" in
		amd64|arm*)
			minikube_arch="${ARCH}" ;;
		ppc64)
			# upstream does not support big-endian ppc64
			minikube_arch="${ARCH}le" ;;
		*)
			die "${ARCH} is not supported" ;;
	esac
	minikube_target="out/minikube-linux-${minikube_arch}"
}

src_compile() {
	# out/docker-machine-driver-kvm2 target is amd64 specific
	# but libvirt useflag is masked on most arches.
	COMMIT=${GIT_COMMIT} \
	COMMIT_NO=${GIT_COMMIT} \
	COMMIT_SHORT=${GIT_COMMIT_SHORT} \
	CGO_LDFLAGS="$(usex hardened '-fno-PIC ' '')" \
	LDFLAGS="" \
	emake \
		$(usex libvirt "out/docker-machine-driver-kvm2" "") \
		"${minikube_target}"
}

src_install() {
	newbin "${minikube_target}" minikube
	use libvirt && dobin out/docker-machine-driver-kvm2
	dodoc -r site CHANGELOG.md README.md

	if ! tc-is-cross-compiler; then
		"${minikube_target}" completion bash > "${T}/bashcomp" || die
		"${minikube_target}" completion fish > "${T}/fishcomp" || die
		"${minikube_target}" completion zsh > "${T}/zshcomp" || die

		newbashcomp "${T}/bashcomp" minikube
		insinto /usr/share/fish/vendor_completions.d
		newins "${T}/fishcomp" minikube.fish
		insinto /usr/share/zsh/site-functions
		newins "${T}/zshcomp" _minikube
	fi
}

pkg_postinst() {
	elog "You may want to install the following optional dependencies:"
	elog "  app-emulation/virtualbox or app-emulation/virtualbox-bin"
	elog "  sys-cluster/kubectl"
}
