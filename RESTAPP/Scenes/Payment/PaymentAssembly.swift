// PaymentAssembly.swift

import UIKit

enum PaymentAssembly {
  static func build(
    items: [OrderItem],
    restaurantId: String
  ) -> UIViewController {
    let interactor = PaymentInteractor(
      items: items,
      restaurantId: restaurantId
    )
    let presenter  = PaymentPresenter()
    let router     = PaymentRouter()
    let vc         = PaymentViewController()

    vc.interactor = interactor
    vc.router     = router
    interactor.presenter     = presenter
    interactor.router        = router
    presenter.viewController = vc
    router.viewController    = vc

    return vc
  }
}
