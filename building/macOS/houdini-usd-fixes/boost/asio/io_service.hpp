// Compatibility shim for Boost 1.88, which folded io_service into io_context.
#pragma once

#include <boost/asio/io_context.hpp>

namespace boost::asio {
using io_service = io_context;
}
